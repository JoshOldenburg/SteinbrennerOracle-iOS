//
//  JOConstants.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOConstants.h"

NSString *const JOExceptionInvalid = @"JOExceptionInvalid";
NSString *const JOErrorDomain = @"JOErrorDomain";
NSString *const JOPreviousItemsKey = @"JOPreviousItems";

@implementation JOUtil

+ (void)setUpTestFlight {
#if JOEnableTF
	[TestFlight setOptions:@{
		TFOptionLogOnCheckpoint: @NO, // Unnecessary
//		TFOptionSendLogOnlyOnCrash: @YES, // So we can TFLog HTTP errors, otherwise will be unused
	}];
	[TestFlight takeOff:@"5fec93db-e9c4-4f5f-b58d-9c5e25f98e4e"];
#endif
}

+ (NSArray *)semideepCopyOfArray:(NSArray *)array {
	NSMutableArray *copiedItems = [NSMutableArray array];
	for (NSObject *object in array) {
		[copiedItems addObject:[object respondsToSelector:@selector(copy)] ? object.copy : object];
	}
	return copiedItems;
}

@end

NSString *JOPreviousItemsPath() {
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = cachePaths.count > 0 ? cachePaths[0] : nil;
	if (!cachePath) return nil;
	if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath] && ![[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil]) return nil;
	return [cachePath stringByAppendingPathComponent:@"JONewsItemCache.plist"];
}
