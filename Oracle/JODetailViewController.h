//
//  JODetailViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@class JONewsItem;

@interface JODetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate>

@property (nonatomic, strong) JONewsItem *newsItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, assign) BOOL usesTextView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
