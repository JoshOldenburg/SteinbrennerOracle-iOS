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
#define JOOracleFeedURL @"http://oraclenewspaper.com/feed/atom/"

#define JOEnableIncrementalRefresh 1 // Whether the items are removed from display while refreshing
#define JOSavePreviousItems (JOEnableIncrementalRefresh && 1) // Whether the items are cached and immediately displayed at open while refreshing
#define JOAlwaysAnimateImageSetting 0

#define JOEnableTF 0 // If 0, calling methods on the TestFlight class is a no-op, as well as the TFLog family
#define JOTFEnableCheckpoints 0

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

#import "TestFlight.h"

@interface JOUtil : NSObject

+ (void)setUpTestFlight;
+ (NSArray *)semideepCopyOfArray:(NSArray *)array; // Only copies first level

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

#if JOCauseErrorForTesting
	#undef JOOracleFeedURL
	#define JOOracleFeedURL @"http://oraclenewspaper.com/ThisPageShouldNotExist"
#endif

#if !JOEnableTF
	#undef JOTFEnableCheckpoints
	#define JOTFEnableCheckpoints 0

	static TestFlight *const _JODisable_TestFlight = nil;
	#define TestFlight ((Class)[_JODisable_TestFlight class])
	#define TFLog NSLog
	#define TFLogv NSLogv
	#define TFLogPreFormatted NSLog
#endif
