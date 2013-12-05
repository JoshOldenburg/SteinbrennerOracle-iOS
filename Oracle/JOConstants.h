//
//  JOConstants.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

// Modifiable. All 0 or 1 unless otherwise noted
#define JOUsePrefPane 0
#define JOCauseErrorForTesting 0
#define JOUseTestingURL 0
#define JOOracleFeedURL @"http://oraclenewspaper.com/feed/atom/"

#define JOEnableIncrementalRefresh 1 // Whether the items are removed from display while refreshing
#define JOSavePreviousItems (JOEnableIncrementalRefresh && 1) // Whether the items are cached and immediately displayed at open while refreshing
#define JOAlwaysAnimateImageSetting 0
#define JOShowCachedItemsInErrorState 0
#define JOEnablePrettificationOfDetail 0 // Whether to use the web page and its formatting or just the HTML from the feed

#import "JOAnalytics.h" // More defines here

/* Defines based on pref pane:
 * JOInfoSectionEnabled
 * JOWebsiteLinkEnabled
 * JODisableImageHeaderUniversally
 * JOEnableImageHeaderOnIOS6
 * All others as above and are not modifiable at run time
 */

extern NSString *const JOExceptionInvalid;
extern NSString *const JOErrorDomain;
extern NSString *const JOPreviousItemsKey;

@interface JOUtil : NSObject

+ (void)setUpAnalytics;
+ (NSArray *)semideepCopyOfArray:(NSArray *)array; // Only copies first level
+ (NSString *)versionString;

@end

NSString *JOPreviousItemsPath(void);

// Implementation details
#if JOUsePrefPane
	#define JOInfoSectionEnabled [[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowInfoSection"] // YES
	#define JOWebsiteLinkEnabled [[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowWebsiteLink"] // YES
	#define JODisableImageHeaderUniversally (![[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowLogoInHeader"]) // NO // This overrides the following
	#define JOEnableImageHeaderOnIOS6 [[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowLogoInHeaderIn6"] // NO
	#warning Using debug pref pane
#else
	#define JOInfoSectionEnabled YES
	#define JOWebsiteLinkEnabled YES
	#define JODisableImageHeaderUniversally NO
	#define JOEnableImageHeaderOnIOS6 NO
#endif

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
