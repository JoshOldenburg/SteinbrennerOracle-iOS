//
//  JOMasterViewController.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOMasterViewController.h"
#import "JODetailViewController.h"
#import "JOImageDetailCell.h"
#import "JONewsFeed.h"
#import "JONewsItem.h"
#import "JONewsFeedInfo.h"
#import "NSString+JOUtilAdditions.h"
#import "UIImageView+AFNetworking.h"

@interface JOMasterViewController () <JONewsFeedDelegate>
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) JONewsFeed *newsFeed;
@property (nonatomic, assign) BOOL shouldDoNothing; // Always NO unless testing
@end

@implementation JOMasterViewController

- (void)awakeFromNib {
	if (NSClassFromString(@"JONewsFeedTests")) {
		self.shouldDoNothing = YES;
		return;
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.preferredContentSize = CGSizeMake(320.0, 600.0);
		self.clearsSelectionOnViewWillAppear = NO;
	}
	
	self.items = [NSMutableArray array];
	self.tableView.rowHeight = 88.0;
	[self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
	
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	
	self.navigationItem.title = @"Steinbrenner Oracle";
	[self jo_updateTitleBarForOrientation:self.interfaceOrientation];
	
	self.navigationController.navigationBar.translucent = NO;
	
	[super awakeFromNib];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) [self jo_updateTitleBarForOrientation:toInterfaceOrientation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) [self jo_updateTitleBarForOrientation:self.interfaceOrientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.feedURL = [NSURL URLWithString:@"http://oraclenewspaper.com/feed/atom/"];
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFeedURL:(NSURL *)feedURL {
	_feedURL = feedURL;
	if (![_feedURL isEqual:feedURL]) self.newsFeed = nil;
	[self jo_setUpFeedParser];
	[self refreshData];
}

- (void)jo_setUpFeedParser {
	if (!self.feedURL || self.shouldDoNothing || self.newsFeed) return;
	
	self.newsFeed = [[JONewsFeed alloc] initWithFeedURL:self.feedURL delegate:self];
}

- (void)refreshData {
	if (self.shouldDoNothing) return;
	self.items = nil;
	[self.tableView reloadData];
	[self.newsFeed start];
}

- (void)clearSelection {
	for (NSIndexPath *selection in self.tableView.indexPathsForSelectedRows) {
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.detailViewController = [segue.destinationViewController isKindOfClass:[JODetailViewController class]] ? segue.destinationViewController : nil;
	self.detailViewController.newsItem = (self.items.count == 0 || self.tableView.indexPathForSelectedRow.section == 1) ? nil : self.items[self.tableView.indexPathForSelectedRow.row];
	if (self.tableView.indexPathForSelectedRow.section == 1) [self prepareDetailForInfoSectionItem:self.tableView.indexPathForSelectedRow];
}

#pragma mark - Util
+ (UIImage *)jo_faviconImage {
	static UIImage *faviconImage;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		faviconImage = [UIImage imageNamed:@"Favicon"];
	});
	return faviconImage;
}

- (void)prepareDetailForInfoSectionItem:(NSIndexPath *)indexPath {
	NSString *textFileName = nil;
	NSString *textFileExtension = nil;
	NSString *title = nil;
	switch (indexPath.row) {
		case 0:
			textFileName = @"AboutSteinbrennerOracle";
			textFileExtension = @"rtf";
			title = @"About the Steinbrenner Oracle";
			break;
		case 1:
			textFileName = @"AboutApp";
			textFileExtension = @"rtf";
			title = @"About the App";
			break;
		default:
			break;
	}
	NSURL *textFileURL = [[NSBundle bundleForClass:self.class] URLForResource:textFileName withExtension:textFileExtension];
	NSAttributedString *text = [[NSAttributedString alloc] initWithFileURL:textFileURL options:[textFileExtension isEqualToString:@"rtf"] ? @{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} : nil documentAttributes:nil error:nil];
	self.detailViewController.usesTextView = YES;
	self.detailViewController.navigationItem.title = title;
	self.detailViewController.textView.attributedText = text ?: [[NSAttributedString alloc] initWithString:@"An error occurred attempting to load the info"];
}

- (void)jo_updateTitleBarForOrientation:(UIInterfaceOrientation)orientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone && self.navigationItem.titleView) return;
	if (UIInterfaceOrientationIsLandscape(orientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		self.navigationItem.titleView = nil;
	} else {
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OracleLogoText"]];
		((UIImageView *)self.navigationItem.titleView).contentMode = UIViewContentModeScaleAspectFit;
	}
}

#pragma mark - NSTableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		if (indexPath.section == 0) {
			self.detailViewController.usesTextView = NO;
			if (indexPath.row < self.items.count) self.detailViewController.newsItem = self.items[indexPath.row];
			else self.detailViewController.newsItem = nil;
		} else {
			[self prepareDetailForInfoSectionItem:indexPath];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.items.count == 0) return NO;
	return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) return self.tableView.rowHeight;
	return 44;
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.items.count > 0 && JOInfoSectionEnabled ? 2 : 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1) return 2;
	return self.items.count > 0 ? self.items.count + ((NSUInteger)JOWebsiteLinkEnabled) : 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return JOInfoSectionEnabled ? @"Latest Articles" : nil;
			break;
		case 1:
			return @"Info";
			break;
		default:
			return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == self.items.count && indexPath.row != 0)) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.section == 1 && indexPath.row == 0) ? @"AboutNewspaperCell" : @"AboutCell"];
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(indexPath.section == 1 && indexPath.row == 0) ? @"AboutNewspaperCell" : @"AboutCell"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		if (indexPath.section == 1) {
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"About the Steinbrenner Oracle";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell.textLabel.text = @"About the App";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				default:
					cell.textLabel.text = @"Error";
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
			}
		} else if (indexPath.row == self.items.count) {
			cell.textLabel.text = @"Open in Browser";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		return cell;
	}
	
	JOImageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsEntry"];
    if (!cell) {
        cell = [[JOImageDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsEntry"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	if (self.items.count == 0) {
		cell.titleLabel.text = @"Loading...";
		cell.blurbLabel.text = @"";
		cell.largeImageView.image = self.class.jo_faviconImage;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
	
    JONewsItem *item = self.items[indexPath.row];
	cell.titleLabel.text = item.title.stringByDecodingHTMLEntities;
	cell.blurbLabel.text = item.summary.stringByDecodingHTMLEntities;
	cell.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	__block JOMasterViewController *_self = self;
	__weak JOImageDetailCell *_cell = cell;
	[item getImageURLsWithCallback:^(NSArray *imageURLs) {
		if (!_cell) return;
//		JOImageDetailCell *_cell = (JOImageDetailCell *)[_self.tableView cellForRowAtIndexPath:indexPath];
		if (!imageURLs || imageURLs.count == 0) {
			_cell.largeImageView.contentMode = UIViewContentModeCenter;
			_cell.largeImageView.image = _self.class.jo_faviconImage;
			return;
		}
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[(NSString *)imageURLs[0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
		
		_cell.largeImageView.contentMode = UIViewContentModeCenter;
		[_cell.largeImageView setImageWithURLRequest:request placeholderImage:_self.class.jo_faviconImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_cell.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
			_cell.largeImageView.image = image;
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			// Will leave placeholder image by default, so do nothing here
		}]; // Caches for us
	}];
    return cell;
}

#pragma mark - JONewsFeedDelegate
- (void)newsFeed:(JONewsFeed *)newsFeed didParseItem:(JONewsItem *)newsItem {
	// No-op, heavy lifting with animations and such is done in newsFeedDidFinishParsing:
}

- (void)newsFeedDidStartDownload:(JONewsFeed *)newsFeed {
	[self.refreshControl beginRefreshing];
//	[self.tableView beginUpdates];
}
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed {
	[self.refreshControl endRefreshing];
	
	NSAssert(newsFeed == self.newsFeed, @"Copied feed parser?");
	NSAssert(newsFeed.newsItems == self.newsFeed.newsItems, @"Copied feed parser (news item array)?");
	
	[self.tableView beginUpdates];
	self.items = newsFeed.newsItems.copy;
	for (JONewsItem *newsItem in self.items) {
		if (self.items[0] == newsItem) {
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
		} else {
			[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.items indexOfObjectIdenticalTo:newsItem] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	} //*/
	
	if (JOInfoSectionEnabled) {
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	
	[self.tableView endUpdates];
}
- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error {
	[self.refreshControl endRefreshing];
//	[self.tableView reloadData];
	NSLog(@"Failed with error: %@", error);
}

@end
