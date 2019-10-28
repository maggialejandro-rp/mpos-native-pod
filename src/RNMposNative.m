#import "RNMposNative.h"
#import "BluetoothState.h"
#import "MposSDK-Swift.h"

@implementation RNMposNative

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onReceiveInitialization",
           @"onReceiveNotification",
           @"onReceiveTableUpdated",
           @"onReceiveFinishTransaction",
           @"onReceiveClose",
           @"onReceiveCardHash",
           @"onReceiveError",
           @"onReceiveOperationCancelled",
           @"onReceiveOperationCompleted",
           @"onBluetoothErrored",
           @"onBluetoothDisconnected"];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(Initialize)
{
  // This is method is not need for iOS, but must be present.
}

RCT_EXPORT_METHOD(setUpListeners)
{
  // This is method is not need for iOS, but must be present.
}

RCT_EXPORT_METHOD(CreateMpos:(NSDictionary *)device encryptionKey:(NSString *)encryptionKey)
{
  CBPeripheral *peripheral = [[BluetoothState sharedState] connectedPeripheral];

  if (peripheral && !self.pinpadManager) {
    self.pinpadManager = [[PinpadManager alloc] initWithDelegate:self
                                                      peripheral:peripheral
                                                  operationQueue:self.methodQueue
                                                   encryptionKey:encryptionKey];
  }
}

RCT_EXPORT_METHOD(OpenConnection:(BOOL)secure)
{
  // secure is not necessary for iOS, but it's here to keep the library compatibility.
  if (self.pinpadManager) {
    [self.pinpadManager connect];
  }
}

RCT_EXPORT_METHOD(DownloadEmvTablesToDevice:(BOOL)forcing)
{
  if (self.pinpadManager) {
    [self.pinpadManager updateTablesForcing:forcing];
  }
}

RCT_EXPORT_METHOD(PayAmount:(NSInteger)amount
                  applications:(NSArray<NSDictionary *> *)applications
                  method:(NSInteger)method)
{
  // applications here is not necessary for iOS, cause the SDK filters applications another way.
  if (self.pinpadManager) {
    PaymentMethod paymentMethod = method == 1 ? PaymentMethodCredit : PaymentMethodDebit;
    [self.pinpadManager payAmount:amount method:paymentMethod];
  }
}

RCT_EXPORT_METHOD(Close:(NSString *)message)
{
  if (self.pinpadManager) {
    [self.pinpadManager disconnectWithMessage:message];
  }
}

RCT_EXPORT_METHOD(CloseConnection)
{
  if (self.pinpadManager) {
    [self.pinpadManager disconnectWithMessage:nil];
  }
}

RCT_EXPORT_METHOD(FinishTransaction:(BOOL)connected code:(NSInteger)code emvData:(NSString *)emvData)
{
  if (self.pinpadManager) {
    [self.pinpadManager finishTransactionWithResponseCode:code connected:connected emvData:emvData];
  }
}

- (void)pinpadManagerIsReadyToReceiveCommands:(PinpadManager *)pinpadManager
{
  [self sendEventWithName:@"onReceiveTableUpdated" body:@YES];
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didConnectToPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  if (!error) {
    [self sendEventWithName:@"onReceiveInitialization" body:@{}];
  } else {
    [self sendEventWithName:@"onReceiveError" body:@(error.code)];
  }
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didProcessPaymentWithCard:(Card *)card cardHash:(NSString *)cardHash error:(NSError *)error
{
  if (!error) {
    [self sendEventWithName:@"onReceiveCardHash" body:@{@"cardHash": cardHash}];
  } else {
    [self sendEventWithName:@"onReceiveError" body:@(error.code)];
  }
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didFinishTransactionWithStatus:(enum TransactionStatus)status
{
  if (status == TransactionStatusSuccess) {
    [self sendEventWithName:@"onReceiveFinishTransaction" body:nil];
  }
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didFailToUpdateTablesDueToError:(NSError *)error
{
  [self sendEventWithName:@"onReceiveError" body:@(error.code)];
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didReceiveData:(NSData *)data error:(NSError *)error
{
  if (error) {
    [self sendEventWithName:@"onBluetoothErrored" body:@(error.code)];
  }
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didReceiveNotification:(NSString *)notification
{
  [self sendEventWithName:@"onReceiveNotification" body:notification];
}

- (void)pinpadManager:(PinpadManager *)pinpadManager didDisconnectFromPeripheral:(CBPeripheral *)peripheral
{
  [self sendEventWithName:@"onBluetoothDisconnected" body:nil];
}

@end
