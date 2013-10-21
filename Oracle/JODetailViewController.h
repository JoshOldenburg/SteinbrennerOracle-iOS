//
//  JODetailViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@class JONewsItem;

@interface JODetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) JONewsItem *newsItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
