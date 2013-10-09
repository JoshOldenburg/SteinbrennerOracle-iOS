//
//  JODetailViewController.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JODetailViewController.h"
#import "MWFeedItem.h"
#import "NSString+HTML.h"

@interface JODetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation JODetailViewController

#pragma mark - Managing the detail item
- (void)setFeedItem:(MWFeedItem *)feedItem {
    if (_feedItem != feedItem) {
        _feedItem = feedItem;
        
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    // Update the user interface for the detail item.

	if (self.feedItem) {
	    [self.webView loadHTMLString:[self.feedItem.summary stringByAppendingString:self.feedItem.content] baseURL:nil];
		self.navigationItem.title = self.feedItem.title.stringByConvertingHTMLToPlainText;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
