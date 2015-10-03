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

+ (void)setUpAnalytics {
	if (JODEBUG) [JOAnalytics setFlurryKey:@"ZKW4DG2XZY5K2G5S2KN3"]; // Testing app
	else [JOAnalytics setFlurryKey:@"FPX9F2Q7Y4Q74FXDVWS8"]; // Production app
//	[JOAnalytics setTestFlightKey:@"5fec93db-e9c4-4f5f-b58d-9c5e25f98e4e"];
	[JOAnalytics startSessionsWithOptions:nil];
}

+ (NSArray *)semideepCopyOfArray:(NSArray *)array {
	NSMutableArray *copiedItems = [NSMutableArray array];
	for (NSObject *object in array) {
		[copiedItems addObject:[object respondsToSelector:@selector(copy)] ? object.copy : object];
	}
	return copiedItems;
}

+ (NSString *)versionString {
	return [NSString stringWithFormat:@"%@ (%@)", [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

@end

NSString *JOPreviousItemsPath() {
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = cachePaths.count > 0 ? cachePaths[0] : nil;
	if (!cachePath) return nil;
	if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath] && ![[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil]) return nil;
	return [cachePath stringByAppendingPathComponent:@"JONewsItemCache.plist"];
}
