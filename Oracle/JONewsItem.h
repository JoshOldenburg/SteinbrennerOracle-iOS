//
//  JONewsItem.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/13/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@interface JONewsItem : NSObject // This does a whole lotta nuttin': this is just for keeping data, with the exception of imageURL's, which will lazyload parse through the content and look for <img> elements and extract the src's

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSDate *publicationDate;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSArray *enclosures;
@property (nonatomic, strong) NSArray *imageURLs;

/*
 * Enclosures array is an array of dictionaries with the keys:
 * - url: URL of the item (NSString)
 * - length: size in bytes (NSNumber)
 * - type: MIME type (NSString)
 */

@end
