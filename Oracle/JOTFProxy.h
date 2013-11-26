//
//  JOTFProxy.h
//  Oracle
//
//  Created by Joshua Oldenburg on 11/26/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOConstants.h"

@interface _JOTFProxy : NSObject

+ (void)addCustomEnvironmentInformation:(NSString *)information forKey:(NSString *)key;
+ (void)takeOff:(NSString *)applicationToken;
+ (void)setOptions:(NSDictionary *)options;
+ (void)passCheckpoint:(NSString *)checkpointName;
+ (void)submitFeedback:(NSString *)feedback;
+ (void)setDeviceIdentifier:(NSString *)deviceIdentifer;

@end
