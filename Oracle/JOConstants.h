//
//  JOConstants.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

// Modifiable. All 0 or 1 unless otherwise noted
#define JOCauseErrorForTesting 0
#define JOUseTestingURL 0
#define JOOracleFeedURL @"http://oraclenewspaper.com/feed/atom/"

#define JOEnableIncrementalRefresh 1 // Whether the items are removed from display while refreshing
#define JOSavePreviousItems (JOEnableIncrementalRefresh && 1) // Whether the items are cached and immediately displayed at open while refreshing
#define JOAlwaysAnimateImageSetting 0
#define JOShowCachedItemsInErrorState 0
#define JOEnablePrettificationOfDetail 0 // Whether to use the web page and its formatting or just the HTML from the feed

#define JOInfoSectionEnabled YES
#define JOWebsiteLinkEnabled YES
#define JOContactLinkEnabled YES
#define JOEnableLinkStrippingInDetail YES
#define JODisableImageHeaderUniversally NO
#define JOEnableImageHeaderOnIOS6 NO

#define JOLog NSLog

extern NSString *const JOExceptionInvalid;
extern NSString *const JOErrorDomain;
extern NSString *const JOPreviousItemsKey;

@interface JOUtil : NSObject

+ (NSArray *)semideepCopyOfArray:(NSArray *)array; // Only copies first level
+ (NSString *)versionString;

@end

NSString *JOPreviousItemsPath(void);

// Implementation details
#if JOUseTestingURL
	#undef JOOracleFeedURL
	#define JOOracleFeedURL @"http://192.168.1.151/OracleWordpress/feed/atom/"
	#warning Using testing URL
#endif

#if JOCauseErrorForTesting
	#undef JOOracleFeedURL
	#define JOOracleFeedURL @"http://oraclenewspaper.com/ThisPageShouldNotExist"
	#warning Causing testing error
#endif

#ifdef DEBUG
	#define JODEBUG 1
#else
	#define JODEBUG 0
#endif
