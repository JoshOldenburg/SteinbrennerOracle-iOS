//
//  JOTFProxy.h
//  Oracle
//
//  Created by Joshua Oldenburg on 11/26/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOConstants.h"

#define JOAnalyticsEnableFlurry 1
#define JOAnalyticsEnableFlurryInDebug 1
#define JOAnalyticsEnableExceptionReporting 1

void JOLog(NSString *, ...);

@interface JOAnalytics : NSObject

+ (void)setFlurryKey:(NSString *)key;
+ (void)startSessionsWithOptions:(id)options;

+ (void)logEvent:(NSString *)event; // Flurry event
+ (void)logEvent:(NSString *)event data:(NSDictionary *)data;
+ (void)logEvent:(NSString *)event timed:(BOOL)timed;
+ (void)logEvent:(NSString *)event data:(NSDictionary *)data timed:(BOOL)timed;
+ (void)endTimedEvent:(NSString *)event;
+ (void)endTimedEvent:(NSString *)event data:(NSDictionary *)data; // data updates the data set from +logEvent:data:timed: if not nil
+ (void)endPreviousTimedEventAmong:(NSArray *)events; // Stops most recent event in array
+ (void)endAllTimedEvents;

+ (void)logException:(NSException *)exception;
+ (void)logException:(NSException *)exception otherInfo:(NSString *)otherInfo, ...;
+ (void)logError:(NSError *)error;
+ (void)logError:(NSError *)error otherInfo:(NSString *)otherInfo, ...;

+ (void)logPageViews:(id)target; // Where target is a UINavigationController or a UITabBarController
+ (void)logPageView; // Logs a single page view

@end

// Private
#if !JOAnalyticsEnableFlurryInDebug && DEBUG && JOAnalyticsEnableFlurry
	#undef JOAnalyticsEnableFlurry
	#define JOAnalyticsEnableFlurry 0
#endif

#if !JOAnalyticsEnableFlurry && !JOAnalyticsEnableTF
	static JOAnalytics *const _JODisable_Analytics = nil;
	#define JOAnalytics ((Class)[_JODisable_TestFlight class])
	#define JOLog NSLog
#endif
