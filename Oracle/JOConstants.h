//
//  JOConstants.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

// Modifiable
#define JOUsePrefPane 0
#define JOCauseErrorForTesting 0 // 0/1
#define JOOracleFeedURL @"http://oraclenewspaper.com/feed/atom/"

/* Defines:
 * JOInfoSectionEnabled
 * JOWebsiteLinkEnabled
 * JODisableImageHeaderUniversally
 * JOEnableImageHeaderOnIOS6
 */

extern NSString *const JOExceptionInvalid;
extern NSString *const JOErrorDomain;

#import "TestFlight.h"

@interface JOUtil : NSObject

+ (void)setUpTestFlight;

@end

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
