//
//  JONewsItem.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/13/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@interface JONewsItem : NSObject <NSCoding> // This does a whole lotta nuttin': this is just for keeping data, with the exception of imageURL's, which will lazyload parse through the content and look for <img> elements and extract the src's

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSDate *publicationDate;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *tidiedContent; // Tidies content with libtidy if this is nil. Will only tidy once, to run again, set this to nil. This is automatically nilled when content is set
@property (nonatomic, strong) NSArray *enclosures;
@property (nonatomic, strong) NSArray *imageURLs;
@property (nonatomic, strong) NSString *alternateURL;

- (void)getImageURLsWithCallback:(void(^)(NSArray *imageURLs))callback; // If the imageURLs have already been parsed, this will call the callback immediately on the calling thread. Otherwise, it will be called on the main thread after the parse is complete

/*
 * imageURLs is an array of NSString URL's. If the content hasn't been parsed for images yet, this will return nil and launch a parse.
 * When the parse is complete this will return the array. If the content has been parsed and there aren't any URL's, this will be an empty array.
 * Set imageURLs to nil to force another parse. This uses tidiedContent, so to re-tidy the content as well, set tidiedContent to nil.
 */

/*
 * enclosures is an array of dictionaries with the keys:
 * - url: URL of the item (NSString)
 * - length: size in bytes (NSNumber)
 * - type: MIME type (NSString)
 */

@end
