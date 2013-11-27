//
//  JONewsItem.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/13/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JONewsItem.h"
#import "tidy.h"
#import "buffio.h"
#import "NSString+JOUtilAdditions.h"

@interface JONewsItem () <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray *tempImageURLs;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableArray *callbacks;
@end

@implementation JONewsItem
@synthesize tidiedContent = _tidiedContent;
@synthesize imageURLs = _imageURLs;

- (id)init {
	self = [super init];
	if (self) {
		_callbacks = [NSMutableArray array];
	}
	return self;
}

- (void)setContent:(NSString *)content {
	if ([_content isEqualToString:content]) return;
	
	_content = content;
	self.tidiedContent = nil;
}

- (NSString *)tidiedContent {
	if (_tidiedContent) return _tidiedContent;
	
	TidyBuffer output = {0};
	TidyDoc tidyDoc = ig_tidyCreate();
    if (!ig_tidyOptSetBool(tidyDoc, TidyXmlOut, yes)) return nil; // Convert to XML
    if (!ig_tidyOptSetValue(tidyDoc, TidyCharEncoding, "utf8")) return nil; // UTF-8
	TidyBuffer errorBuffer = {0};
	if (ig_tidySetErrorBuffer(tidyDoc, &errorBuffer) < 0) return nil; // Shut up tidy: puts errors to stderr if this isn't set
    if (ig_tidyParseString(tidyDoc, self.content.UTF8String) < 0) return nil; // Parse
    if (ig_tidyCleanAndRepair(tidyDoc) < 0) return nil; // Fix/tidy
    if (ig_tidySaveBuffer(tidyDoc, &output) < 0) return nil; // Save
	
	return _tidiedContent = [NSString stringWithUTF8String:(char *)output.bp];
}
- (void)setTidiedContent:(NSString *)tidiedContent {
	if ([_tidiedContent isEqualToString:tidiedContent]) return;
	
	_tidiedContent = tidiedContent;
	self.imageURLs = nil;
}

- (NSArray *)imageURLs {
	if (_imageURLs) return _imageURLs;
	
	[self getImageURLsWithCallback:nil];
	return nil;
}
- (void)setImageURLs:(NSArray *)imageURLs {
	if ([_imageURLs isEqualToArray:imageURLs]) return;
	
	_imageURLs = imageURLs;
	self.parser = nil;
	self.tempImageURLs = nil;
	[self.callbacks removeAllObjects];
}
- (void)getImageURLsWithCallback:(void (^)(NSArray *imageURLs))callback {
	if (_imageURLs) {
		if (callback) callback(self.imageURLs);
		return;
	}
	
	if (!self.callbacks) self.callbacks = [NSMutableArray array];
	if (callback) [self.callbacks addObject:callback];
	if (self.parser) return;
	
	self.parser = [[NSXMLParser alloc] initWithData:[[self.tidiedContent stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "] dataUsingEncoding:NSUTF8StringEncoding]];
	self.parser.delegate = self;
	[self.parser parse];
}

- (BOOL)imageURLsAreLoaded {
	return !!_imageURLs;
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.tempImageURLs = [NSMutableArray array];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"img"] && attributeDict[@"src"]) [self.tempImageURLs addObject:attributeDict[@"src"]];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSArray *callbacks = self.callbacks.copy;
	_imageURLs = self.tempImageURLs;
	for (void (^callback)(NSArray *imageURLs) in callbacks) {
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(_imageURLs);
		});
		[self.callbacks removeObject:callback];
	}
	self.parser = nil;
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.tempImageURLs = nil;
	[self parserDidEndDocument:parser];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self && aDecoder) {
		_identifier = [aDecoder decodeObjectForKey:@"JOCodingIdentifier"];
		_publicationDate = [aDecoder decodeObjectForKey:@"JOCodingPublicationDate"];
		_updateDate = [aDecoder decodeObjectForKey:@"JOCodingUpdateDate"];
		_title = [aDecoder decodeObjectForKey:@"JOCodingTitle"];
		_summary = [aDecoder decodeObjectForKey:@"JOCodingSummary"];
		_enclosures = [aDecoder decodeObjectForKey:@"JOCodingEnclosures"];
		_alternateURL = [aDecoder decodeObjectForKey:@"JOCodingAlternateURL"];
		_imageURLs = [aDecoder decodeObjectForKey:@"JOCodingImageURLs"];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
	if (!aCoder) return;
	if (_identifier) [aCoder encodeObject:_identifier forKey:@"JOCodingIdentifier"];
	if (_publicationDate) [aCoder encodeObject:_publicationDate forKey:@"JOCodingPublicationDate"];
	if (_updateDate) [aCoder encodeObject:_updateDate forKey:@"JOCodingUpdateDate"];
	if (_title) [aCoder encodeObject:_title forKey:@"JOCodingTitle"];
	if (_summary) [aCoder encodeObject:_summary forKey:@"JOCodingSummary"];
	if (_enclosures) [aCoder encodeObject:_enclosures forKey:@"JOCodingEnclosures"];
	if (_alternateURL) [aCoder encodeObject:_alternateURL forKey:@"JOCodingAlternateURL"];
	if (_imageURLs && _shouldArchiveImageURLs) [aCoder encodeObject:_imageURLs forKey:@"JOCodingImageURLs"];
}

#pragma NSObject
- (NSUInteger)hash {
	return self.identifier.hash ^ self.publicationDate.hash;
}
- (BOOL)isEqual:(JONewsItem *)object {
	if (!object || ![object isKindOfClass:self.class]) return NO;
	if (object == self) return YES;
	return [self.identifier isEqualToString:object.identifier] && [self.publicationDate isEqualToDate:object.publicationDate];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	JONewsItem *copy = [[JONewsItem alloc] init];
	copy->_title = _title.copy;
	copy->_publicationDate = _publicationDate.copy;
	copy->_updateDate = _updateDate.copy;
	copy->_title = _title.copy;
	copy->_summary = _summary.copy;
	copy->_content = _content.copy;
	copy->_tidiedContent = _tidiedContent.copy;
	copy->_enclosures = _enclosures.copy;
	copy->_imageURLs = _imageURLs.copy;
	copy->_alternateURL = _alternateURL.copy;
	return copy;
}

@end
