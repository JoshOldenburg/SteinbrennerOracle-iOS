//
//  JOConstants.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

extern NSString *const JOExceptionInvalid;
extern NSString *const JOErrorDomain;

#define JOInfoSectionEnabled [[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowInfoSection"] // YES
#define JOWebsiteLinkEnabled [[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowWebsiteLink"] // YES

#define JODisableImageHeaderUniversally (![[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowLogoInHeader"]) // NO // This overrides the following
#define JOEnableImageHeaderOnIOS6 [[NSUserDefaults standardUserDefaults] boolForKey:@"JOPrefShowLogoInHeaderIn6"] // NO

#define JOCauseErrorForTesting 0 // Please, preprocessor, make NO == 0 and YES == 1 in macros...

#if JOCauseErrorForTesting
#define JOOracleFeedURL @"http://oraclenewspaper.com/ThisPageShouldNotExist"
#else
#define JOOracleFeedURL @"http://oraclenewspaper.com/feed/atom/"
#endif

@interface JOUtil : NSObject

@end
