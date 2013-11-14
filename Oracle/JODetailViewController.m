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
#import "UIWebView+AFNetworking.h"

@interface JODetailViewController ()
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, assign) BOOL hasHiddenElements;
@end

@implementation JODetailViewController

- (void)awakeFromNib {
	[super awakeFromNib];
	if (!self.isViewLoaded) [self loadView];
	self.navigationController.navigationBar.translucent = NO;
	self.webView.delegate = self;
	[self jo_updateBarButtonVisible:NO];
	[self jo_updateHiddenWithTextViewHidden:!self.usesTextView];
}
- (void)jo_showMasterIfNecessary UNAVAILABLE_ATTRIBUTE { // Don't use, doesn't work anyways
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && !self.masterPopoverController && !self.newsItem && !self.usesTextView && self.navigationItem) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action];
#pragma clang diagnostic pop
	}
}

#pragma mark - Managing the detail item
- (void)setNewsItem:(JONewsItem *)newsItem {
	if (_newsItem != newsItem) {
		_newsItem = newsItem;
		[self.webView loadHTMLString:@"" baseURL:nil];
		[self configureView];
	}
	
	[self jo_dismissPopovers];
}
- (void)setUsesTextView:(BOOL)usesTextView {
	if (usesTextView) {
		_newsItem = nil;
		[self.webView loadHTMLString:@"" baseURL:nil];
	}
	
	[self jo_updateHiddenWithTextViewHidden:!(_usesTextView = usesTextView)];
	[self jo_dismissPopovers];
}

- (void)configureView {
	if (self.newsItem) {
		[self jo_updateHiddenWithTextViewHidden:YES];
		if (JOEnablePrettificationOfDetail && self.newsItem.alternateURL) {
			[self.activityIndicator startAnimating];
			self.webView.hidden = YES;
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.newsItem.alternateURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
			[request addValue:[NSString stringWithFormat:@"%@ (%@)", [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Oracle-App-Version"];
			[request addValue:[NSString stringWithFormat:@"OracleMobileIOS"] forHTTPHeaderField:@"User-Agent"];
			__block JODetailViewController *weakSelf = self;
			[self.webView loadRequest:request progress:nil success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
				weakSelf.hasHiddenElements = NO;
#if JOEnablePrettificationOfDetail
				dispatch_async(dispatch_get_main_queue(), ^{
					[weakSelf jo_removeAllElementsButContentAndDisplay];
				});
#endif
				return [HTML stringByAppendingString:self.jo_hidingJS];
			} failure:^(NSError *error) {
				[weakSelf.webView loadHTMLString:weakSelf.newsItem.content baseURL:nil];
				TFLog(@"Error loading request, falling back to default: %@", error);
			}];
		} else {
			[self.webView loadHTMLString:self.newsItem.content baseURL:nil];
		}
		[self jo_updateBarButtonVisible:YES];
		self.navigationItem.title = self.newsItem.title.stringByConvertingHTMLToPlainText;
	} else if (self.usesTextView) {
		[self jo_updateHiddenWithTextViewHidden:NO];
		[self jo_updateBarButtonVisible:NO];
		self.navigationItem.title = @"Select an Article";
	} else {
		[self jo_updateHiddenWithTextViewHidden:YES];
		[self jo_updateBarButtonVisible:NO];
		self.navigationItem.title = @"Select an Article";
	}
}

- (NSString *)jo_hidingJS {
#if JOEnablePrettificationOfDetail
	NSURL *jsURL = [[NSBundle bundleForClass:self.class] URLForResource:@"hideallelements" withExtension:@"js"];
	NSString *js = [NSString stringWithContentsOfURL:jsURL encoding:NSUTF8StringEncoding error:nil] ?: @"";
	NSRange range = [js rangeOfString:@"// JO_END_EXECUTABLE"];
	return [js substringToIndex:range.location - 1];
#else
	return @"";
#endif
}
#if JOEnablePrettificationOfDetail
- (void)jo_removeAllElementsButContentAndDisplay {
	[self.activityIndicator stopAnimating];
	self.webView.hidden = NO;
}
#endif

- (void)jo_updateHiddenWithTextViewHidden:(BOOL)textViewHidden {
	self.textView.hidden = textViewHidden;
	self.textView.scrollsToTop = !textViewHidden;
	self.webView.hidden = !textViewHidden;
	self.webView.scrollView.scrollsToTop = textViewHidden;
}
- (void)jo_updateBarButtonVisible:(BOOL)barButtonVisible {
	if (barButtonVisible && self.newsItem.alternateURL) [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed:)] animated:YES];
	else [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)jo_dismissPopovers {
	[self.masterPopoverController dismissPopoverAnimated:YES];
	[self.sharePopoverController dismissPopoverAnimated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self configureView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	if (!self.usesTextView) self.textView.attributedText = nil;
	if (self.usesTextView) [self.webView loadHTMLString:@"" baseURL:nil];
}

#pragma mark - Actions
- (void)shareButtonPressed:(id)sender {
	NSMutableArray *items = [NSMutableArray arrayWithObject:self.newsItem.alternateURL];
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
	activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact];
	
	[self jo_dismissPopovers];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		self.modalPresentationStyle = UIModalPresentationFullScreen;
		self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentViewController:activityViewController animated:YES completion:nil];
	} else {
		self.sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
		[self.sharePopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
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

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

@end
