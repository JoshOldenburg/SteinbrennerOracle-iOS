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
#import "NSString+JOUtilAdditions.h"

@interface JONewsFeedTests : XCTestCase <JONewsFeedDelegate>
@property (nonatomic, assign) BOOL hasFinishedParsing;
@property (nonatomic, assign) BOOL parseFailed;
@property (nonatomic, strong, readonly) NSURL *feedURL;
@end

@implementation JONewsFeedTests

- (void)setUp {
	[super setUp];
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"JONewsFeedTest.localhost"];
	} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
		return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(request.URL.path, nil) statusCode:200 headers:@{
			@"Content-Type": @"text/xml"
		}];
	}];
	
	self.hasFinishedParsing = NO;
	self.continueAfterFailure = YES;
	self.parseFailed = NO;
}
- (void)tearDown {
	[OHHTTPStubs removeAllStubs];
	[super tearDown];
}

- (NSURL *)feedURL {
	return [[NSURL alloc] initWithScheme:@"http" host:@"JONewsFeedTest.localhost" path:@"/ExampleAtomFeed.xml"];
}

- (JONewsFeed *)createFeedAndLoadWithURL:(NSURL *)feedURL {
	XCTAssertNotNil(feedURL);
	JONewsFeed *feed = [[JONewsFeed alloc] initWithFeedURL:self.feedURL delegate:self];
	XCTAssertNotNil(feed);
	
	[self loadFeed:feed];
	return feed;
}
- (void)loadFeed:(JONewsFeed *)feed {
	XCTAssertNotNil(feed);
	
	self.hasFinishedParsing = NO;
	self.parseFailed = NO;
	
	[feed start];
	JOWaitForTrueWithExpiration(&_hasFinishedParsing, [NSDate dateWithTimeIntervalSinceNow:5]);
	XCTAssertFalse(self.parseFailed, @"Parse failed");
	XCTAssertTrue(self.hasFinishedParsing, @"Took >5 seconds to parse");
}

#pragma mark - Tests
- (void)testLoad {
	JONewsFeed *feed = [self createFeedAndLoadWithURL:self.feedURL];
	
	XCTAssertNotNil(feed.feedInfo);
	XCTAssertEqualObjects(feed.feedInfo.title, @"The Steinbrenner High School Oracle");
	XCTAssertEqualObjects(feed.feedInfo.link, @"http://www.oraclenewspaper.com");
	
	XCTAssertNotNil(feed.newsItems);
	XCTAssertEqual(feed.newsItems.count, (NSUInteger)2, @"Did not completely parse");
	XCTAssertTrue([feed.newsItems[0] isKindOfClass:[JONewsItem class]], @"Item is of incorrect class type");
	XCTAssertTrue([feed.newsItems[1] isKindOfClass:[JONewsItem class]], @"Item is of incorrect class type");
	XCTAssertEqualObjects(((JONewsItem *)feed.newsItems[0]).title.stringByConvertingHTMLToPlainText, @"Swim falls to Plant in season’s conclusion"); // Fancy quote (’), not straight quote (')
	XCTAssertEqualObjects(((JONewsItem *)feed.newsItems[0]).identifier, @"http://www.oraclenewspaper.com/?p=8117");
}

- (void)testImageURLs {
	JONewsFeed *feed = [self createFeedAndLoadWithURL:self.feedURL];
	
	XCTAssertEqual(feed.newsItems.count, (NSUInteger)2, @"Did not completely parse");
	JONewsItem *firstItem = feed.newsItems[1];
	XCTAssertNotNil(firstItem);
	__block BOOL isComplete = NO;
	[firstItem getImageURLsWithCallback:^(NSArray *imageURLs) {
		isComplete = YES;
	}];
	JOWaitForTrueWithExpiration(&isComplete, [NSDate dateWithTimeIntervalSinceNow:5]);
	XCTAssertTrue(isComplete, @"Took >5 seconds to load image URLs");
	XCTAssertNotNil(firstItem.imageURLs, @"Failed to load image URLs");
	XCTAssertEqual(firstItem.imageURLs.count, (NSUInteger)1, @"Did not completely parse image URLs");
	XCTAssertEqualObjects(firstItem.imageURLs[0], @"http://www.oraclenewspaper.com/wp-content/uploads/2013/10/American-Horror-Story-Coven-Jessica-Lange-Kathy-Bates-300x153.png");
}

- (void)testAlternateLinks {
	JONewsFeed *feed = [self createFeedAndLoadWithURL:self.feedURL];
	
	XCTAssertEqual(feed.newsItems.count, (NSUInteger)2, @"Did not completely parse");
	XCTAssertEqualObjects(((JONewsItem *)feed.newsItems[0]).alternateURL, @"http://www.oraclenewspaper.com/2013/10/18/unable-claim-win-final-meet-season/");
}

- (void)testMultipleLoads {
	JONewsFeed *feed = [self createFeedAndLoadWithURL:self.feedURL];
	XCTAssertNotNil(feed.feedInfo);
	XCTAssertEqual(feed.newsItems.count, (NSUInteger)2, @"Did not completely parse");
	
	[self loadFeed:feed];
	XCTAssertNotNil(feed.feedInfo);
	XCTAssertEqual(feed.newsItems.count, (NSUInteger)2, @"Did not completely reparse");
}

- (void)testInitParamaterChecking {
	XCTAssertThrowsSpecificNamed([[JONewsFeed alloc] init], NSException, JOExceptionInvalid);
	XCTAssertNil([[JONewsFeed alloc] initWithFeedURL:nil delegate:self]);
	XCTAssertNotNil([[JONewsFeed alloc] initWithFeedURL:self.feedURL delegate:nil]);
}

- (void)testAuthor {
	JONewsFeed *feed = [self createFeedAndLoadWithURL:self.feedURL];
	
	XCTAssertEqualObjects(((JONewsItem *)feed.newsItems[0]).author, @"EmmaS");
}

#pragma mark - JONewsFeedDelegate
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed {
	self.hasFinishedParsing = YES;
}
- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error {
	self.hasFinishedParsing = YES;
	self.parseFailed = YES;
	XCTFail(@"Parse failed with error: %@", error);
}

@end
