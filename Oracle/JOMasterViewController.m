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
#import "AFURLConnectionOperation.h" // Imported for error parsing

static const UITableViewRowAnimation JORowUpdateAnimation = UITableViewRowAnimationRight;

@interface JOMasterViewController () <JONewsFeedDelegate>
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) JONewsFeed *newsFeed;
@property (nonatomic, strong) NSError *previousLoadError;
@property (nonatomic, assign) BOOL shouldDoNothing; // Always NO unless testing
@end

@implementation JOMasterViewController

- (void)awakeFromNib {
	if (NSClassFromString(@"JONewsFeedTests")) {
		self.shouldDoNothing = YES;
		return;
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    if ([self respondsToSelector:@selector(setPreferredContentSize:)]) self.preferredContentSize = CGSizeMake(320.0, 600.0);
		else self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		self.clearsSelectionOnViewWillAppear = NO;
	}
	
#if JOSavePreviousItems
	NSString *cachePath = JOPreviousItemsPath();
	if (cachePath) self.items = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath]; // Throws exception only if the archive is invalid/corrupted
#endif
	if (!self.items) self.items = @[];
	self.tableView.rowHeight = 88.0;
	[self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
	
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	
	self.navigationItem.title = @"Steinbrenner Oracle";
	[self jo_updateTitleBarForOrientation:self.interfaceOrientation];
	
	self.navigationController.navigationBar.translucent = NO;
	
	self.clearsSelectionOnViewWillAppear = NO;
	
#if JOUsePrefPane
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jo_updateForPrefsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
#endif
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jo_cacheItems:) name:UIApplicationWillTerminateNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jo_cacheItems:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	[super awakeFromNib];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	
	self.feedURL = [NSURL URLWithString:JOOracleFeedURL];
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self jo_updateTitleBarForOrientation:self.interfaceOrientation];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || [self jo_indexPathIsWebsiteLink:self.tableView.indexPathForSelectedRow]) [self jo_clearSelection];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
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
	self.newsFeed.customRequestHeaders = @{
		@"X-Oracle-App-Version": [NSString stringWithFormat:@"%@ (%@)", [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleVersion"]],
	};
}

- (void)jo_updateForPrefsChanged:(id)sender {
	[self.tableView reloadData]; // TODO: prettify this
	[self jo_updateTitleBarForOrientation:self.interfaceOrientation];
}

- (void)refreshData {
	if (self.shouldDoNothing) return;
#if !JOEnableIncrementalRefresh
	self.items = nil;
#endif
	self.previousLoadError = nil;
	if (self.items.count == 0) [self.tableView reloadData]; // [nil count] == 0
	[self.newsFeed start];
}

- (void)jo_clearSelection {
	for (NSIndexPath *selection in self.tableView.indexPathsForSelectedRows) {
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.detailViewController = [segue.destinationViewController isKindOfClass:[JODetailViewController class]] ? segue.destinationViewController : nil;
	[self prepareDetailViewControllerForIndexPath:self.tableView.indexPathForSelectedRow];
}

#pragma mark - Util
- (void)jo_cacheItems:(id)sender {
	NSString *cachePath = JOPreviousItemsPath();
	if (!cachePath) return;
#if 1 // 1 for debugging update (it caches all but the first item), 0 for normal
#warning Debugging caching
	NSArray *items = [[JOUtil semideepCopyOfArray:self.items] subarrayWithRange:self.items.count > 0 ? NSMakeRange(1, self.items.count - 1) : NSMakeRange(0, self.items.count)];
	((JONewsItem *)items.lastObject).title = @"Debuggifying";
	((JONewsItem *)items.lastObject).identifier = @"debuggificationID";
	if (NO) {
		JONewsItem *firstItem = items.count > 1 ? items[0] : nil;
		firstItem.title = @"Debuggifying first item";
		firstItem.identifier = @"debuggificationID2";
	}
	[NSKeyedArchiver archiveRootObject:items toFile:cachePath];
#else
	[NSKeyedArchiver archiveRootObject:self.items toFile:cachePath];
#endif
}

+ (UIImage *)jo_faviconImage {
	static UIImage *faviconImage;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		faviconImage = [UIImage imageNamed:@"O"];
	});
	return faviconImage;
}

- (void)prepareDetailViewControllerForIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		self.detailViewController.usesTextView = NO;
		if ([self jo_indexPathIsWebsiteLink:indexPath]) {
			self.detailViewController.newsItem = nil;
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://oraclenewspaper.com"]];
			if (JOTFEnableCheckpoints) [TestFlight passCheckpoint:@"OpenedWebsite"];
			[self jo_clearSelection];
		} else {
			self.detailViewController.newsItem = self.items[indexPath.row];
			if (JOTFEnableCheckpoints) [TestFlight passCheckpoint:@"OpenedNewsItem"];
		}
	} else {
		[self prepareDetailForInfoSectionItem:indexPath];
	}
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
			if (JOTFEnableCheckpoints) [TestFlight passCheckpoint:@"OpenedAboutSteinbrennerOracle"];
			break;
		case 1:
			textFileName = @"AboutApp";
			textFileExtension = @"rtf";
			title = @"About the App";
			if (JOTFEnableCheckpoints) [TestFlight passCheckpoint:@"OpenedAboutApp"];
			break;
		default:
			break;
	}
	NSURL *textFileURL = [[NSBundle bundleForClass:self.class] URLForResource:textFileName withExtension:textFileExtension];
	NSURL *plaintextFileURL = [[NSBundle bundleForClass:self.class] URLForResource:textFileName withExtension:@"txt"];
	NSAttributedString *text;
	if ([NSAttributedString instancesRespondToSelector:@selector(initWithFileURL:options:documentAttributes:error:)]) {
		text = [[NSAttributedString alloc] initWithFileURL:textFileURL options:[textFileExtension isEqualToString:@"rtf"] ? @{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} : nil documentAttributes:nil error:nil];
	} else {
		NSString *plaintext = [NSString stringWithContentsOfURL:plaintextFileURL usedEncoding:nil error:nil];
		if (plaintext) text = [[NSAttributedString alloc] initWithString:plaintext];
	}
	self.detailViewController.usesTextView = YES;
	self.detailViewController.navigationItem.title = title;
	self.detailViewController.textView.attributedText = text ?: [[NSAttributedString alloc] initWithString:@"An error occurred attempting to load the info"];
}

- (void)jo_updateTitleBarForOrientation:(UIInterfaceOrientation)orientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone && self.navigationItem.titleView) return;
	if ((UIInterfaceOrientationIsLandscape(orientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) || (!JOEnableImageHeaderOnIOS6 && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) || JODisableImageHeaderUniversally) { // No NSFoundationVersionNumber_iOS_7_0 as of yet
		self.navigationItem.titleView = nil;
	} else if (!self.navigationItem.titleView) {
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TheORACLE"]];
		((UIImageView *)self.navigationItem.titleView).contentMode = UIViewContentModeScaleAspectFit;
	}
}

- (BOOL)jo_indexPathIsWebsiteLink:(NSIndexPath *)indexPath {
	return JOWebsiteLinkEnabled && indexPath && (indexPath.section == 0 && indexPath.row == self.items.count && indexPath.row != 0);
}

#pragma mark - NSTableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || [self jo_indexPathIsWebsiteLink:indexPath]) {
		[self prepareDetailViewControllerForIndexPath:indexPath];
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((self.items.count == 0 && !self.previousLoadError) || (self.previousLoadError && indexPath.section == 0)) return NO;
	return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && (indexPath.row < self.items.count || (indexPath.row == 0))) return self.tableView.rowHeight;
	return 44;
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ((self.items.count > 0 || self.previousLoadError) && JOInfoSectionEnabled) ? 2 : 1;
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
	BOOL isWebsiteLinkCell = [self jo_indexPathIsWebsiteLink:indexPath];
	if (indexPath.section == 1 || isWebsiteLinkCell) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:isWebsiteLinkCell ? @"NoSegueCell" : @"MiscCell"];
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:isWebsiteLinkCell ? @"NoSegueCell" : @"MiscCell"];
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
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
					cell.textLabel.text = @"Error: Invalid row";
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
			}
		} else if (isWebsiteLinkCell) {
			cell.textLabel.text = @"Read more online";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		return cell;
	}
	
	JOImageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsEntry"];
    if (!cell) {
        cell = [[JOImageDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsEntry"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
	
	if (self.previousLoadError) {
		if ([self.previousLoadError.domain isEqualToString:NSURLErrorDomain] && self.previousLoadError.code == NSURLErrorNotConnectedToInternet) {
			cell.titleLabel.text = @"Could not connect to the Internet";
			cell.blurbLabel.text = @"Turn off airplane mode or use Wi-Fi to access data";
		} else if ([self.previousLoadError.domain isEqualToString:AFNetworkingErrorDomain]  && self.previousLoadError.code == NSURLErrorBadServerResponse && [self.previousLoadError.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *response = self.previousLoadError.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
			NSInteger statusCode = response.statusCode; // Separated out for debugging
			cell.titleLabel.text = [NSString stringWithFormat:@"An error occurred loading news: %ld (%ld)", (long)self.previousLoadError.code, (long)statusCode];
			switch (statusCode) {
				case 404: // Not Found
				case 406: // Not Acceptable
				case 410: // Gone
					cell.blurbLabel.text = @"The Oracle's website has been updated and is incompatible with this app.";
					break;
				case 401: // Unauthorized
				case 403: // Forbidden
					cell.blurbLabel.text = @"The Oracle's website is down or has blocked this app from accessing it.";
					break;
				case 418: // I'm a teapot
					cell.blurbLabel.text = @"The Oracle's web server has informed you that it is a teapot.";
					break;
				case 450: // Blocked by Windows Parental Controls
					cell.blurbLabel.text = @"Parental controls have blocked the Oracle's website.";
					break;
				case 500: // Internal Server Error
				case 502: // Bad Gateway
				case 503: // Service Unavailable
				case 504: // Gateway Timeout
					cell.blurbLabel.text = @"An unknown error occurred on the Oracle's website.";
					break;
				default:
					cell.blurbLabel.text = @"Pleae try again later.";
					break;
			}
			TFLog(@"Error loading Oracle website data: HTTP %ld (NSError: %@), gave message: %@", (long)statusCode, self.previousLoadError, cell.blurbLabel.text);
		} else if (self.previousLoadError) {
			cell.titleLabel.text = [NSString stringWithFormat:@"Error loading news: %ld", (long)self.previousLoadError.code];
			cell.blurbLabel.text = self.previousLoadError.localizedDescription;
			TFLog(@"Error loading Oracle website data: %@", self.previousLoadError);
		} else {
			cell.titleLabel.text = @"An unknown error occurred loading news";
			cell.blurbLabel.text = @"Please try again later.";
			TFLog(@"Error loading Oracle website data: %@", self.previousLoadError);
		}
		cell.largeImageView.contentMode = UIViewContentModeCenter;
		cell.largeImageView.image = self.class.jo_faviconImage;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	} else if (self.items.count == 0) {
		cell.titleLabel.text = @"Loading...";
		cell.blurbLabel.text = @"";
		cell.largeImageView.contentMode = UIViewContentModeCenter;
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
		if (!imageURLs || imageURLs.count == 0) {
			_cell.largeImageView.contentMode = UIViewContentModeCenter;
			_cell.largeImageView.image = _self.class.jo_faviconImage;
			return;
		}
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[(NSString *)imageURLs[0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
		
		_cell.largeImageView.contentMode = UIViewContentModeCenter;
		[_cell.largeImageView setImageWithURLRequest:request placeholderImage:_self.class.jo_faviconImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			dispatch_block_t setImageBlock = ^{
				_cell.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
				_cell.largeImageView.image = image;
			};
			if (!self.tableView.dragging || JOAlwaysAnimateImageSetting) [UIView transitionWithView:_cell.largeImageView duration:0.25f options:UIViewAnimationOptionTransitionCrossDissolve animations:setImageBlock completion:nil];
			else setImageBlock(); // Don't animate setting of image when the user is dragging
		} failure:nil]; // Caches for us
	}];
    return cell;
}

#pragma mark - JONewsFeedDelegate
- (void)newsFeedDidStartDownload:(JONewsFeed *)newsFeed {
	[self.refreshControl beginRefreshing];
}
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed {
	if (![NSThread isMainThread]) return [self performSelectorOnMainThread:@selector(newsFeedDidFinishParsing:) withObject:newsFeed waitUntilDone:YES];
	
	[self.refreshControl endRefreshing];
	
	NSAssert(newsFeed == self.newsFeed, @"Copied feed parser?");
	
	[self.tableView beginUpdates];
#if JOEnableIncrementalRefresh
	NSArray *oldItems = self.items;
#else
	NSArray *oldItems = nil;
#endif
	self.items = newsFeed.newsItems.copy;
	if (oldItems.count > 0) {
		for (JONewsItem *newsItem in oldItems) {
			if ([self.items indexOfObject:newsItem] == NSNotFound) { // In old items, but not in new
				[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[oldItems indexOfObjectIdenticalTo:newsItem] inSection:0]] withRowAnimation:JORowUpdateAnimation];
			} else {
				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[oldItems indexOfObjectIdenticalTo:newsItem] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
			}
		}
	}
	for (JONewsItem *newsItem in self.items) {
		newsItem.shouldArchiveImageURLs = YES;
		if (self.items[0] == newsItem && oldItems.count == 0) {
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:JORowUpdateAnimation];
		} else if (!oldItems || [oldItems indexOfObject:newsItem] == NSNotFound) {
			[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.items indexOfObjectIdenticalTo:newsItem] inSection:0]] withRowAnimation:JORowUpdateAnimation];
		}
	}
	
	[self jo_cacheItems:self];
	
	if (JOWebsiteLinkEnabled && oldItems.count == 0) [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.items.count inSection:0]] withRowAnimation:JORowUpdateAnimation];
	
	if (JOInfoSectionEnabled && oldItems.count == 0) {
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:JORowUpdateAnimation];
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:JORowUpdateAnimation];
	}
	
	[self.tableView endUpdates];
}
- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error {
	[self.refreshControl endRefreshing];
	self.previousLoadError = error;
	[self.tableView reloadData];
}

@end
