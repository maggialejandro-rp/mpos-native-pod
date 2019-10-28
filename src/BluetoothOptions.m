//
//  BluetoothOptions.m
//  RNMposNative
//
//  Created by Murilo Paixão on 28/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "BluetoothOptions.h"

@implementation BluetoothOptions

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
  self = [super init];

  if (self) {
    NSString *allowDuplicate = [[dictionary valueForKey:@"allowDuplicate"] stringValue];
    self.allowDuplicate = [allowDuplicate boolValue];

    NSString *allowNullNames = [[dictionary valueForKey:@"allowNullNames"] stringValue];
    self.allowNullNames = [allowNullNames boolValue];

    self.scanTime = [[[dictionary valueForKey:@"scanTime"] stringValue] integerValue];
  }

  return self;
}

@end
