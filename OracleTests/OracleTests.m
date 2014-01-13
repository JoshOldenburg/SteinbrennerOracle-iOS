//
//  OracleTests.m
//  OracleTests
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+JOUtilAdditions.h"

@interface OracleTests : XCTestCase
@end

@implementation OracleTests

- (void)testStringAdditions {
	XCTAssertEqualObjects([@"<a href=\"/foo/bar/baz\">ASDF</a>" stringByStrippingLinks], @"<a>ASDF</a>");
	XCTAssertEqualObjects([@"<a class=\"foo\" href=\"/foo/bar/baz\">" stringByStrippingLinks], @"<a class=\"foo\">");
	XCTAssertEqualObjects([@"<a href=\"/foo/bar/baz\" class=\"foo\">" stringByStrippingLinks], @"<a class=\"foo\">");
	XCTAssertEqualObjects([@"<a id=\"bar\" href=\"/foo/bar/baz\" class=\"foo\">" stringByStrippingLinks], @"<a id=\"bar\" class=\"foo\">");
	XCTAssertEqualObjects([@"<a id=\"bar\" class=\"foo\">" stringByStrippingLinks], @"<a id=\"bar\" class=\"foo\">");
}

@end
