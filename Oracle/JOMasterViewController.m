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

@interface JOMasterViewController () <JONewsFeedDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) JONewsFeed *feedParser;
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
	self.navigationItem.title = @"Steinbrenner Oracle";
	self.detailViewController = (JODetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	[super awakeFromNib];
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
	[self jo_setUpFeedParser];
	[self refreshData];
}

- (void)jo_setUpFeedParser {
	if (!self.feedURL || self.shouldDoNothing) return;
	
	self.feedParser = [[JONewsFeed alloc] initWithFeedURL:self.feedURL delegate:self];
}

- (void)refreshData {
	if (self.shouldDoNothing) return;
	[self.items removeAllObjects];
	[self.tableView reloadData];
	[self.feedParser start];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.detailViewController = segue.destinationViewController;
	self.detailViewController.newsItem = self.items[self.tableView.indexPathForSelectedRow.row];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	JOImageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsEntry"];
    if (cell == nil) {
        cell = [[JOImageDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewsEntry"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    JONewsItem *item = self.items[indexPath.row];
	cell.titleLabel.text = item.title.stringByDecodingHTMLEntities;
	cell.textView.text = item.summary.stringByDecodingHTMLEntities;
#warning TODO: make async
	if (item.imageURLs.count > 0) {
		cell.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
		cell.largeImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.imageURLs[0]]]];
	} else {
		cell.largeImageView.contentMode = UIViewContentModeCenter;
		cell.largeImageView.image = [UIImage imageNamed:@"Favicon"];
	}
    return cell;
}

#pragma mark - NSTableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.detailViewController.newsItem = self.items[indexPath.row];
	}
}

#pragma mark - MWFeedParserDelegate
- (void)newsFeed:(JONewsFeed *)newsFeed didParseItems:(NSArray *)newsItems {
	JOMasterViewController *_self = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		[_self.items setArray:newsItems];
		[self.tableView reloadData];
	});
}

- (void)newsFeedDidStartDownload:(JONewsFeed *)newsFeed {
	[self.refreshControl beginRefreshing];
}
- (void)newsFeedDidFinishParsing:(JONewsFeed *)newsFeed {
	[self.refreshControl endRefreshing];
}
- (void)newsFeed:(JONewsFeed *)newsFeed didFailWithError:(NSError *)error {
	[self.refreshControl endRefreshing];
	NSLog(@"Failed with error: %@", error);
}

@end
