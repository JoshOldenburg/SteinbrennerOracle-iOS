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

- (void)awakeFromNib {
	[super awakeFromNib];
	if (!self.isViewLoaded) [self loadView];
	self.navigationController.navigationBar.translucent = NO;
//	self.usesTextView = self.usesTextView;
//	self.newsItem = self.newsItem;
	self.textView.hidden = !self.usesTextView;
	self.webView.hidden = self.usesTextView;
}

#pragma mark - Managing the detail item
- (void)setNewsItem:(JONewsItem *)newsItem {
	if (_newsItem != newsItem) {
		_newsItem = newsItem;
		[self.webView loadHTMLString:@"" baseURL:nil];
		[self configureView];
	}
	
	if (self.masterPopoverController != nil) [self.masterPopoverController dismissPopoverAnimated:YES];
}
- (void)setUsesTextView:(BOOL)usesTextView {
	if (usesTextView) {
		_newsItem = nil;
		[self.webView loadHTMLString:@"" baseURL:nil];
	}
	
//	NSAssert(self.textView, @"textView is nil");
	[self jo_updateHiddenWithTextViewHidden:!(_usesTextView = usesTextView)];
	if (self.masterPopoverController != nil) [self.masterPopoverController dismissPopoverAnimated:YES];
}

- (void)configureView {
	if (self.newsItem) {
		[self jo_updateHiddenWithTextViewHidden:YES];
		[self.webView loadHTMLString:self.newsItem.content baseURL:nil];
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed:)] animated:YES];
		self.navigationItem.title = self.newsItem.title.stringByConvertingHTMLToPlainText;
	} else if (self.usesTextView) {
		[self jo_updateHiddenWithTextViewHidden:NO];
		self.navigationItem.title = @"Select an Article";
	} else {
		[self jo_updateHiddenWithTextViewHidden:YES];
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
		self.navigationItem.title = @"Select an Article";
	}
}

- (void)jo_updateHiddenWithTextViewHidden:(BOOL)textViewHidden {
	self.textView.hidden = textViewHidden;
	self.textView.scrollsToTop = !textViewHidden;
	self.webView.hidden = !textViewHidden;
	self.webView.scrollView.scrollsToTop = textViewHidden;
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
