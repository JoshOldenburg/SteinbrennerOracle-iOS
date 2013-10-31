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

@implementation JOUtil

+ (void)setUpTestFlight {
	[TestFlight setOptions:@{
		TFOptionLogOnCheckpoint: @NO, // Unnecessary
//		TFOptionSendLogOnlyOnCrash: @YES, // So we can TFLog HTTP errors, otherwise will be unused
	}];
	[TestFlight takeOff:@"5fec93db-e9c4-4f5f-b58d-9c5e25f98e4e"];
}

@end
