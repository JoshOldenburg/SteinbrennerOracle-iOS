//
//  JONewsFeedTests.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/18/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

// Imports OracleTests.h for JOWaitForTrue and friends
#import <XCTest/XCTest.h>
#import "OracleTests.h"
#import "OHHTTPStubs.h"
#import "JONewsFeed.h"
#import "JONewsFeedInfo.h"
#import "JONewsItem.h"

@interface JONewsFeedTests : XCTestCase <JONewsFeedDelegate>
@property (nonatomic, assign) BOOL hasParsedInfo;
@property (nonatomic, assign) BOOL hasFinishedParsing;
@property (nonatomic, assign) BOOL parseFailed;
@end

@implementation JONewsFeedTests

- (void)setUp {
	[super setUp];
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"JONewsFeedTest.localhost"];
	} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
		return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"ExampleAtomFeed.xml", nil) statusCode:200 headers:@{
			@"Content-Type": @"text/xml"
		}];
	}];
	
	self.hasParsedInfo = NO;
	self.hasFinishedParsing = NO;
	self.continueAfterFailure = NO;
	self.parseFailed = NO;
}
- (void)tearDown {
	[OHHTTPStubs removeAllStubs];
	[super tearDown];
}

- (NSURL *)feedURL {
	return [[NSURL alloc] initWithScheme:@"http" host:@"JONewsFeedTest.localhost" path:@"/ExampleAtomFeed.xml"];
}

- (void)testLoad {
	JONewsFeed *feed = [[JONewsFeed alloc] initWithFeedURL:self.feedURL delegate:self];
	XCTAssertNotNil(feed);
	
	[feed start];
	JOWaitForTrueWithExpiration(&_hasFinishedParsing, [NSDate dateWithTimeIntervalSinceNow:5]);
	XCTAssertFalse(self.parseFailed, @"Parse failed");
	XCTAssertTrue(self.hasParsedInfo, @"Took >5 seconds to parse info");
	XCTAssertNotNil(feed.feedInfo);
	XCTAssertEqualObjects(feed.feedInfo.title, @"The Steinbrenner High School Oracle");
	XCTAssertEqualObjects(feed.feedInfo.link, @"http://www.oraclenewspaper.com");
}

#pragma mark - JONewsFeedDelegate
- (void)newsFeed:(JONewsFeed *)newsFeed didParseInfo:(JONewsFeedInfo *)feedInfo {
	self.hasParsedInfo = YES;
}
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed {
	self.hasFinishedParsing = YES;
}
- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error {
	self.hasFinishedParsing = YES;
	self.parseFailed = YES;
	XCTFail(@"Parse failed with error: %@", error);
}

@end
