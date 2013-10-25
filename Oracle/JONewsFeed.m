//
//  JONewsFeed.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/13/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JONewsFeed.h"
#import "JONewsItem.h"
#import "JONewsFeedInfo.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLResponseSerialization.h"
#import "NSString+JOUtilAdditions.h"
#import "NSDate+InternetDateTime.h"
#import "TBXML.h"

// Empty XHTML elements ( <!ELEMENT br EMPTY> in http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd )
#define ELEMENT_IS_EMPTY(e) ([e isEqualToString:@"br"] || [e isEqualToString:@"img"] || [e isEqualToString:@"input"] || [e isEqualToString:@"hr"] || [e isEqualToString:@"link"] || [e isEqualToString:@"base"] || [e isEqualToString:@"basefont"] || [e isEqualToString:@"frame"] || [e isEqualToString:@"meta"] || [e isEqualToString:@"area"] || [e isEqualToString:@"col"] || [e isEqualToString:@"param"])

@interface JONewsFeed () <NSXMLParserDelegate>
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLRequest *URLRequest;
@property (nonatomic, strong) JONewsFeedInfo *feedInfo;
@property (nonatomic, strong) NSArray *newsItems;
@property (nonatomic, assign) JONewsFeedType feedType;
@property (nonatomic, assign, getter = isStarted) BOOL started;
@property (nonatomic, assign, getter = isWorking) BOOL working;
@property (nonatomic, assign) BOOL latestParseDidFail;
@end

@implementation JONewsFeed

#pragma mark - Initializers
- (instancetype)initWithFeedURL:(NSURL *)feedURL delegate:(id<JONewsFeedDelegate>)delegate {
	if (!feedURL) return (self = nil);
	
	self = [super init];
	if (self) {
		_feedURL = feedURL;
		_delegate = delegate;
		_queue = [[NSOperationQueue alloc] init];
		_queue.name = @"com.joshuaoldenburg.Oracle.newsfeed";
		
		_newsItems = [NSArray array];
		
		_timeoutInterval = 15.0;
		_cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	}
	return self;
}
- (instancetype)init {
	@throw [NSException exceptionWithName:JOExceptionInvalid reason:@"You must use -initWithFeedURL:delegate:" userInfo:nil];
	return (self = nil);
}

#pragma mark - Public
- (void)start {
	if (self.working) return;
	self.started = YES;
	self.working = YES;
	self.latestParseDidFail = NO;
	[self jo_createRequestIfNecessary];
	self.newsItems = @[];
	
	AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:self.URLRequest];
	{
		__block JONewsFeed *this = self;
		[request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id _responseObject) {
			[this jo_parseWithData:operation.responseData];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[this jo_finishWithError:error];
		}];
	}
	request.responseSerializer = [AFHTTPResponseSerializer serializer];
	request.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", @"application/atom+xml", nil];
	[self.queue addOperation:request];
	
	if ([self.delegate respondsToSelector:@selector(newsFeedDidStartDownload:)]) [self.delegate newsFeedDidStartDownload:self];
}

- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
	if (self.started) return;
	_cachePolicy = cachePolicy;
}
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
	if (self.started) return;
	_timeoutInterval = timeoutInterval;
}

#pragma mark - Misc Private
- (void)jo_createRequestIfNecessary {
	if (self.URLRequest) return;
	NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:self.feedURL cachePolicy:self.cachePolicy timeoutInterval:self.timeoutInterval];
	self.URLRequest = URLRequest;
}

- (void)jo_parseWithData:(NSData *)data {
	if ([self.delegate respondsToSelector:@selector(newsFeedDidSuccessfullyFinishDownload:)]) [self.delegate newsFeedDidSuccessfullyFinishDownload:self];
	
	NSError *error;
	TBXML *XML = [[TBXML alloc] initWithXMLData:data error:&error];
	if (!XML || error || !XML.rootXMLElement) {
		[self jo_finishWithError:error];
		return;
	}
	
	NSString *rootElementName = [TBXML elementName:XML.rootXMLElement];
	if ([rootElementName isEqualToString:@"feed"]) [self jo_parseAtomFeedWithXML:XML];
	else if ([rootElementName isEqualToString:@"rss"]) [self jo_parseRSSFeedWithXML:XML];
	else if ([rootElementName isEqualToString:@"rdf:RDF"]) [self jo_parseRDFFeedWithXML:XML];
	else [self jo_finishWithErrorDescription:@"Invalid feed type" code:JONewsFeedErrorInvalidFeed];
	
	self.working = NO;
	if (!self.latestParseDidFail && [self.delegate respondsToSelector:@selector(newsFeedDidFinishParsing:)]) [self.delegate newsFeedDidFinishParsing:self];
}
- (void)jo_parseAtomFeedWithXML:(TBXML *)XML {
	self.feedType = JONewsFeedTypeAtom;
	
	{
		JONewsFeedInfo *feedInfo = [[JONewsFeedInfo alloc] init];
		
		TBXMLElement *titleItem = [TBXML childElementNamed:@"title" parentElement:XML.rootXMLElement];
		if (titleItem) feedInfo.title = [TBXML textForElement:titleItem];
		
		TBXMLElement *descriptionItem = [TBXML childElementNamed:@"description" parentElement:XML.rootXMLElement];
		if (descriptionItem) feedInfo.summary = [TBXML textForElement:descriptionItem];
		
		TBXMLElement *linkItem = [TBXML childElementNamed:@"link" parentElement:XML.rootXMLElement];
		if (linkItem) [self jo_parseAtomLink:linkItem intoFeedInfo:feedInfo];
		
		self.feedInfo = feedInfo;
		
		if ([self.delegate respondsToSelector:@selector(newsFeed:didParseInfo:)]) [self.delegate newsFeed:self didParseInfo:self.feedInfo];
	}
	
	{
		__block JONewsFeed *_self = self;
		TBXMLElement *element = [TBXML childElementNamed:@"entry" parentElement:XML.rootXMLElement];
		do {
			JONewsItem *newsItem = [[JONewsItem alloc] init];
			
			TBXMLElement *titleElement = [TBXML childElementNamed:@"title" parentElement:element];
			if (titleElement) newsItem.title = [TBXML textForElement:titleElement];
			
			TBXMLElement *linkElement = [TBXML childElementNamed:@"link" parentElement:element];
			if (linkElement) [self jo_parseAtomLink:linkElement intoNewsItem:newsItem];
			
			TBXMLElement *idElement = [TBXML childElementNamed:@"id" parentElement:element];
			if (idElement) newsItem.identifier = [TBXML textForElement:idElement];
			
			TBXMLElement *summaryElement = [TBXML childElementNamed:@"summary" parentElement:element];
			if (summaryElement) newsItem.summary = [TBXML textForElement:summaryElement];
			
			TBXMLElement *contentElement = [TBXML childElementNamed:@"content" parentElement:element];
			if (contentElement) newsItem.content = [TBXML textForElement:contentElement];
			
			TBXMLElement *publicationDateElement = [TBXML childElementNamed:@"published" parentElement:element];
			if (publicationDateElement) newsItem.publicationDate = [NSDate dateFromRFC3339String:[TBXML textForElement:publicationDateElement]];
			
			TBXMLElement *updateDateElement = [TBXML childElementNamed:@"updated" parentElement:element];
			if (updateDateElement) newsItem.updateDate = [NSDate dateFromRFC3339String:[TBXML textForElement:updateDateElement]];
			
			_self.newsItems = [_self.newsItems arrayByAddingObject:newsItem];
			if ([_self.delegate respondsToSelector:@selector(newsFeed:didParseItem:)]) [_self.delegate newsFeed:_self didParseItem:newsItem];
		} while ((element = [TBXML nextSiblingNamed:@"entry" searchFromElement:element]));
	}
}
- (void)jo_parseAtomLink:(TBXMLElement *)link intoFeedInfo:(JONewsFeedInfo *)feedInfo {
	if (!link || !feedInfo) return;
	
	NSString *relValue = [TBXML valueOfAttributeNamed:@"rel" forElement:link];
	if (!relValue || ![relValue isEqualToString:@"alternate"]) return;
	
	feedInfo.link = [TBXML valueOfAttributeNamed:@"href" forElement:link];
}
- (void)jo_parseAtomLink:(TBXMLElement *)link intoNewsItem:(JONewsItem *)newsItem {
	if (!link || !newsItem) return;
	
	NSString *relValue = [TBXML valueOfAttributeNamed:@"rel" forElement:link];
	if (!relValue || ![relValue isEqualToString:@"enclosure"]) return;
	
	[self jo_parseEnclosureElement:link intoNewsItem:newsItem];
}

- (void)jo_parseRSSFeedWithXML:(TBXML *)XML {
	[self jo_finishWithErrorDescription:@"Invalid feed type" code:JONewsFeedErrorInvalidFeed];
}
- (void)jo_parseRDFFeedWithXML:(TBXML *)XML {
	[self jo_finishWithErrorDescription:@"Invalid feed type" code:JONewsFeedErrorInvalidFeed];
}

- (void)jo_parseEnclosureElement:(TBXMLElement *)element intoNewsItem:(JONewsItem *)newsItem {
	if (!element || !newsItem) return;
	
	NSMutableDictionary *enclosure = [NSMutableDictionary dictionaryWithCapacity:3];
	NSString *enclosureURL;
	NSString *enclosureType;
	NSNumber *enclosureLength;
	
	switch (self.feedType) {
		case JONewsFeedTypeAtom:
			enclosureURL = [TBXML valueOfAttributeNamed:@"href" forElement:element];
			enclosureType = [TBXML valueOfAttributeNamed:@"type" forElement:element];
			enclosureLength = @([TBXML valueOfAttributeNamed:@"length" forElement:element].longLongValue);
			break;
		default:
			return;
	}
	
	if (!enclosureURL) return;
	enclosure[@"url"] = enclosureURL;
	if (enclosureType) enclosure[@"type"] = enclosureType;
	if (enclosureLength) enclosure[@"length"] = enclosureLength;
	
	if (newsItem.enclosures) newsItem.enclosures = [newsItem.enclosures arrayByAddingObject:[NSDictionary dictionaryWithDictionary:enclosure]];
	else newsItem.enclosures = [NSArray arrayWithObject:[NSDictionary dictionaryWithDictionary:enclosure]];
}

- (void)jo_finishWithError:(NSError *)error {
	self.working = NO;
	
	if ([self.delegate respondsToSelector:@selector(newsFeed:didFailWithError:)]) [self.delegate newsFeed:self didFailWithError:error];
}
- (void)jo_finishWithErrorDescription:(NSString *)errorDescription code:(JONewsFeedError)errorCode {
	[self jo_finishWithError:[NSError errorWithDomain:JOErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorDescription}]];
}

@end
