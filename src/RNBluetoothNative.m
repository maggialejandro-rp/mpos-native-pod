//
//  RNBluetoothNative.m
//  RNMposNative
//
//  Created by Murilo Paixão on 28/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNBluetoothNative.h"
#import "BluetoothState.h"

#define BLUETOOTH_STATE_BONDED 12
#define BLUETOOTH_STATE_BONDING 11

#define PERIPHERAL_CONNECTION_TIMEOUT 3

@implementation RNBluetoothNative

- (instancetype)init
{
  self = [super init];

  if (self) {
    self.discoveredDevices = [NSMutableArray array];
  }

  return self;
}

// MARK: React Native
+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onDeviceReceive", @"onPairResult", @"onConnectionTimeout"];
}

// MARK: Module Exports
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(SetOptions:(NSDictionary *)optionsDictionary)
{
  NSLog(@"RNBluetoothNative SetOptions: %@", optionsDictionary);
  self.options = [[BluetoothOptions alloc] initWithDictionary:optionsDictionary];
}

RCT_EXPORT_METHOD(StartDiscovery)
{
  NSDictionary *bluetoothOptions = @{CBCentralManagerOptionShowPowerAlertKey: @YES};
  self.central = [[CBCentralManager alloc] initWithDelegate:self queue:self.methodQueue options:bluetoothOptions];
}

RCT_EXPORT_METHOD(Dispose)
{
  NSLog(@"RNBluetoothNative Dispose");

  if (self.central != nil && self.central.isScanning) {
    [self.central stopScan];
    [self.discoveredDevices removeAllObjects];
  }
}

RCT_EXPORT_METHOD(PairWith:(NSDictionary *)deviceDictionary)
{
  NSString *identifier = (NSString *) [deviceDictionary objectForKey:@"address"];
  CBPeripheral *peripheralToPair = [self findPeripheralWithIdentifier:identifier];

  if (peripheralToPair) {
    [self.central connectPeripheral:peripheralToPair options:nil];
    [self sendEventWithName:@"onPairResult" body:@{@"deviceAddress": peripheralToPair.identifier.UUIDString,
                                                   @"result": @(BLUETOOTH_STATE_BONDING)}];

    self.peripheralConnectionTimeout = [NSTimer scheduledTimerWithTimeInterval:PERIPHERAL_CONNECTION_TIMEOUT
                                                                        target:self
                                                                      selector:@selector(peripheralConnectionDidTimeout:)
                                                                      userInfo:peripheralToPair
                                                                       repeats:NO];
  }
}

// MARK: CoreBluetooth
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  if (central.state == CBManagerStatePoweredOn) {
    NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey: @(self.options.allowDuplicate)};
    [central scanForPeripheralsWithServices:nil options:scanOptions];
  }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
  if (!self.options.allowNullNames && (peripheral.name == nil || [peripheral.name isEqualToString:@""])) {
    return;
  }

  if (![self.discoveredDevices containsObject:peripheral]) {
    [self.discoveredDevices addObject:peripheral];

    dispatch_async(self.methodQueue, ^{
      [self sendEventWithName:@"onDeviceReceive" body:@{@"name": peripheral.name,
                                                        @"address": peripheral.identifier.UUIDString}];
    });
  }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
  dispatch_async(self.methodQueue, ^{
    if (self.peripheralConnectionTimeout) {
      [self.peripheralConnectionTimeout invalidate];
      self.peripheralConnectionTimeout = nil;
    }

    [[BluetoothState sharedState] setConnectedPeripheral:peripheral];
    [self sendEventWithName:@"onPairResult" body:@{@"deviceAddress": peripheral.identifier.UUIDString,
                                                   @"result": @(BLUETOOTH_STATE_BONDED)}];
  });
}

- (CBPeripheral *)findPeripheralWithIdentifier:(NSString *)identifier
{
  for (CBPeripheral *peripheral in self.discoveredDevices) {
    if ([peripheral.identifier.UUIDString isEqualToString:identifier]) {
      return peripheral;
    }
  }

  return nil;
}

- (void)peripheralConnectionDidTimeout:(NSTimer *)timer
{
  CBPeripheral *failingPeripheral = (CBPeripheral *) timer.userInfo;
  [self.central cancelPeripheralConnection:failingPeripheral];

  [self sendEventWithName:@"onConnectionTimeout" body:@{@"name": failingPeripheral.name,
                                                        @"address": failingPeripheral.identifier.UUIDString}];
}

@end
