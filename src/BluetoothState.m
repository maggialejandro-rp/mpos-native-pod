//
//  BluetoothState.m
//  RNMposNative
//
//  Created by Murilo Paixão on 31/01/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "BluetoothState.h"

@implementation BluetoothState

+ (id)sharedState
{
  static BluetoothState *sharedState = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    sharedState = [[self alloc] init];
  });
  return sharedState;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.connectedPeripheral = nil;
  }
  return self;
}

@end
