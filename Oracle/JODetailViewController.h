//
//  JODetailViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@class MWFeedItem;

@interface JODetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) MWFeedItem *feedItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
