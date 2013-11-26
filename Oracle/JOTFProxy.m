//
//  JOTFProxy.m
//  Oracle
//
//  Created by Joshua Oldenburg on 11/26/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOTFProxy.h"

@interface _JOTFProxy ()
+ (NSMutableArray *)passedOffCheckpoints;
+ (BOOL)hasPassedOffCheckpoint:(NSString *)checkpoint;
@end

@implementation _JOTFProxy

#pragma mark - TestFlight
+ (void)addCustomEnvironmentInformation:(NSString *)information forKey:(NSString *)key {
	[_TestFlight addCustomEnvironmentInformation:information forKey:key];
}

+ (void)takeOff:(NSString *)applicationToken {
	[_TestFlight takeOff:applicationToken];
}

+ (void)setOptions:(NSDictionary *)options {
	[_TestFlight setOptions:options];
}

+ (void)passCheckpoint:(NSString *)checkpointName {
	[_TestFlight passCheckpoint:checkpointName];
}

+ (void)submitFeedback:(NSString *)feedback {
	[_TestFlight submitFeedback:feedback];
}

+ (void)setDeviceIdentifier:(NSString *)deviceIdentifer {
	[_TestFlight setDeviceIdentifier:deviceIdentifer];
}

#pragma mark - Custom
+ (NSMutableArray *)passedOffCheckpoints {
	static NSMutableArray *_passedOffCheckpoints;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_passedOffCheckpoints = [NSMutableArray array];
	});
	return _passedOffCheckpoints;
}
+ (BOOL)hasPassedOffCheckpoint:(NSString *)checkpoint {
	return [self.passedOffCheckpoints containsObject:checkpoint];
}

@end
