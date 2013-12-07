//
//  JOTFProxy.m
//  Oracle
//
//  Created by Joshua Oldenburg on 11/26/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOAnalytics.h"
#import "JOConstants.h"
#import "TestFlight.h"
#import "Flurry.h"

void JOLog(NSString *format, ...) {
	if (!format) return;
	
	va_list args;
	va_start(args, format);
	NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	if (JOAnalyticsEnableTF) TFLogPreFormatted(format);
	if (JOAnalyticsEnableFlurry) [Flurry logEvent:@"Log message" withParameters:[NSDictionary dictionaryWithObject:string forKey:@"Message"]];
	NSLog(@"%@", string);
}

void _JOAnalyticsExceptionHandler(NSException *exception) {
	[JOAnalytics logException:exception];
}

@interface JOAnalytics ()
@property (nonatomic, strong) NSString *testFlightKey;
@property (nonatomic, strong) NSString *flurryKey;
@property (nonatomic, strong) NSMutableArray *timedEventStack;
@end

@implementation JOAnalytics

+ (void)setTestFlightKey:(NSString *)key {
	self.jo_sharedAnalytics.testFlightKey = key;
}
+ (void)setFlurryKey:(NSString *)key {
	self.jo_sharedAnalytics.flurryKey = key;
}
+ (void)startSessionsWithOptions:(id)options {
	if (JOAnalyticsEnableExceptionReporting && JOAnalyticsEnableFlurry) NSSetUncaughtExceptionHandler(&_JOAnalyticsExceptionHandler);
	if (JOAnalyticsEnableTF && self.testFlightKey) [TestFlight takeOff:self.testFlightKey];
	if (JOAnalyticsEnableFlurry && self.flurryKey) [Flurry startSession:self.flurryKey withOptions:options];
}

+ (void)logEvent:(NSString *)event {
	[self logEvent:event data:nil timed:NO];
}
+ (void)logEvent:(NSString *)event data:(NSDictionary *)data {
	[self logEvent:event data:data timed:NO];
}
+ (void)logEvent:(NSString *)event timed:(BOOL)timed {
	[self logEvent:event data:nil timed:timed];
}
+ (void)logEvent:(NSString *)event data:(NSDictionary *)data timed:(BOOL)timed {
	if (!event) {
		NSLog(@"Must specify event name!");
		return;
	}
	
	if (JOAnalyticsEnableTF) [TestFlight passCheckpoint:event];
	if (JOAnalyticsEnableFlurry) [Flurry logEvent:event withParameters:data timed:timed];
	
	if (timed) {
		NSDictionary *stackObject = @{@"name": event, @"data": data ?: [NSNull null]};
		[self.timedEventStack insertObject:stackObject atIndex:0];
	}
}
+ (void)endTimedEvent:(NSString *)event {
	[self endTimedEvent:event data:nil];
}
+ (void)endTimedEvent:(NSString *)event data:(NSDictionary *)data {
	if (JOAnalyticsEnableFlurry) [Flurry endTimedEvent:event withParameters:data];
	
	for (NSDictionary *stackObject in self.timedEventStack) {
		if ([stackObject[@"name"] isEqual:event]) {
			[self.timedEventStack removeObject:stackObject];
			return;
		}
	}
}
+ (void)endPreviousTimedEventAmong:(NSArray *)events {
	if (self.timedEventStack.count == 0 || events.count == 0) return;
	for (NSDictionary *stackObject in self.timedEventStack) {
		if ([events containsObject:stackObject[@"name"]]) {
			[self endTimedEvent:stackObject[@"name"] data:([stackObject[@"data"] isKindOfClass:[NSNull class]] ? nil : stackObject[@"data"])];
//			[self.timedEventStack removeObject:stackObject]; // Already happens in +endTimedEvent:data:
			return;
		}
	}
}
+ (void)endAllTimedEvents {
	NSArray *stack = self.timedEventStack.copy;
	[self.timedEventStack removeAllObjects];
	for (NSString *event in stack) {
		[self endTimedEvent:event];
	}
}

+ (void)logException:(NSException *)exception {
	[self logException:exception otherInfo:nil];
}
+ (void)logException:(NSException *)exception otherInfo:(NSString *)otherInfo, ... {
	if (otherInfo) {
		va_list args;
		va_start(args, otherInfo);
		otherInfo = [[NSString alloc] initWithFormat:otherInfo arguments:args];
		va_end(args);
	}
	
	if (JOAnalyticsEnableFlurry) [Flurry logError:@"Exception" message:otherInfo exception:exception];
}
+ (void)logError:(NSError *)error {
	[self logError:error otherInfo:nil];
}
+ (void)logError:(NSError *)error otherInfo:(NSString *)otherInfo, ... {
	if (otherInfo) {
		va_list args;
		va_start(args, otherInfo);
		otherInfo = [[NSString alloc] initWithFormat:otherInfo arguments:args];
		va_end(args);
	}
	
	if (JOAnalyticsEnableFlurry) [Flurry logError:@"Error" message:otherInfo error:error];
}

+ (void)logPageViews:(id)target {
	if (JOAnalyticsEnableFlurry) [Flurry logAllPageViews:target];
}
+ (void)logPageView {
	if (JOAnalyticsEnableFlurry) [Flurry logPageView];
}

#pragma mark - "Properties"
+ (JOAnalytics *)jo_sharedAnalytics {
	static JOAnalytics *singleton;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singleton = [[JOAnalytics alloc] init];
	});
	return singleton;
}

+ (NSString *)testFlightKey { return self.jo_sharedAnalytics.testFlightKey; }
+ (NSString *)flurryKey { return self.jo_sharedAnalytics.flurryKey; }
+ (NSMutableArray *)timedEventStack { return self.jo_sharedAnalytics.timedEventStack ?: (self.jo_sharedAnalytics.timedEventStack = [NSMutableArray array]); }

@end
