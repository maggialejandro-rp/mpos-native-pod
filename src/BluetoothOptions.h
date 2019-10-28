//
//  BluetoothOptions.h
//  RNMposNative
//
//  Created by Murilo Paixão on 28/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothOptions : NSObject

@property (assign) BOOL allowDuplicate;
@property (assign) BOOL allowNullNames;
@property (assign) NSInteger scanTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
