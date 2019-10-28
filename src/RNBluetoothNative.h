//
//  RNBluetoothNative.h
//  RNMposNative
//
//  Created by Murilo Paixão on 28/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#import "BluetoothOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNBluetoothNative : RCTEventEmitter <RCTBridgeModule, CBCentralManagerDelegate>

@property (strong, atomic) NSMutableArray<CBPeripheral *> *discoveredDevices;
@property (strong, nonatomic) BluetoothOptions *options;

@property (strong, nonatomic, nullable) NSTimer *peripheralConnectionTimeout;

@property (strong, nonatomic) CBCentralManager *central;

@end

NS_ASSUME_NONNULL_END
