#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#import <CoreBluetooth/CoreBluetooth.h>

@protocol PinpadManagerDelegate;
@class PinpadManager;

@interface RNMposNative : RCTEventEmitter <RCTBridgeModule, PinpadManagerDelegate>

@property (strong, nonatomic) PinpadManager *pinpadManager;

@end
