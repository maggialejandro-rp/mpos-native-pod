//
//  BluetoothState.h
//  RNMposNative
//
//  Created by Murilo Paixão on 31/01/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothState : NSObject

@property (strong, nonatomic, nullable) CBPeripheral *connectedPeripheral;

+ (id)sharedState;

@end

NS_ASSUME_NONNULL_END
