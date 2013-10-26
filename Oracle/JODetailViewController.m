//
//  JODetailViewController.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JODetailViewController.h"
#import "JONewsItem.h"
#import "NSString+JOUtilAdditions.h"

@interface JODetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation JODetailViewController

#pragma mark - Managing the detail item
- (void)setNewsItem:(JONewsItem *)newsItem {
	if (_newsItem != newsItem) {
		_newsItem = newsItem;
		[self configureView];
	}
	
	if (self.masterPopoverController != nil) [self.masterPopoverController dismissPopoverAnimated:YES];
}

- (void)configureView {
	if (self.newsItem) {
		[self.webView loadHTMLString:self.newsItem.content baseURL:nil];
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed:)] animated:YES];
		self.navigationItem.title = self.newsItem.title.stringByConvertingHTMLToPlainText;
	} else {
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
		self.navigationItem.title = @"Select an Article";
	}
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self configureView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (void)shareButtonPressed:(id)sender {
	
}

#pragma mark - Split view
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
	barButtonItem.title = @"Articles";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.masterPopoverController = nil;
}

@end
