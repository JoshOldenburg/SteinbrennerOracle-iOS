//
//  OracleTests.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/18/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

void JOWaitForTrueWithExpiration(BOOL *value, NSDate *giveUpDate) {
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	while (!*value && [runLoop runMode:NSDefaultRunLoopMode beforeDate:giveUpDate]);
}
void JOWaitForTrue(BOOL *value) {
	JOWaitForTrueWithExpiration(value, [NSDate distantFuture]);
}
