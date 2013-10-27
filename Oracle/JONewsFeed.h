//
//  JONewsFeed.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/13/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

typedef enum {
	JONewsFeedTypeUnknown = 0,
	JONewsFeedTypeAtom = 1,
//	JONewsFeedTypeRSS = 2, // Unimplemented
//	JONewsFeedTypeRDF = 3, // Unimplemented
} JONewsFeedType;

typedef enum {
	JONewsFeedErrorNone = 0,
	JONewsFeedErrorUnknown = -1,
	
	JONewsFeedErrorInvalidFeed = 1,
	JONewsFeedErrorMalformedFeed = 2,
} JONewsFeedError;

@class JONewsFeed, JONewsItem, JONewsFeed, JONewsFeedInfo;

@protocol JONewsFeedDelegate <NSObject>
@optional

- (void)newsFeedDidStartDownload:(JONewsFeed *)newsFeed; // Called by -start
- (void)newsFeedDidSuccessfullyFinishDownload:(JONewsFeed *)newsFeed; // Called when download finishes successfully

- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error; // Called when download finishes unsuccessfully or when parse fails

- (void)newsFeed:(JONewsFeed *)newsFeed didParseItem:(JONewsItem *)newsItem; // Called after parsing every item and when the feed is done
- (void)newsFeed:(JONewsFeed *)newsFeed didParseInfo:(JONewsFeedInfo *)feedInfo; // Called after parsing feed info
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed; // Called when all items & the info are parsed (if present)

@end

@interface JONewsFeed : NSObject

- (instancetype)initWithFeedURL:(NSURL *)feedURL delegate:(id<JONewsFeedDelegate>)delegate; // Must use this initializer

- (void)start; // Can be called multiple times as long as -working is false. If -working is true this will fail silently
@property (nonatomic, assign, readonly, getter = isWorking) BOOL working;

@property (nonatomic, strong, readonly) JONewsFeedInfo *feedInfo;
@property (nonatomic, strong, readonly) NSArray *newsItems; // Array of `JONewsItem`s
@property (nonatomic, assign, readonly) JONewsFeedType feedType;

@property (nonatomic, strong, readonly) NSURL *feedURL;
@property (nonatomic, weak, readonly) id<JONewsFeedDelegate> delegate;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy; // These cannot be changed after calling -start
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, copy) NSDictionary *customRequestHeaders;

@end
