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
#import "MWFeedParser.h"
#import "NSString+HTML.h"

@interface JOMasterViewController () <MWFeedParserDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) MWFeedParser *feedParser;
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
//	[self.tableView registerNib:[UINib nibWithNibName:@"JOImageDetailCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"NewsEntry"];
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
	
	self.feedParser = [[MWFeedParser alloc] initWithFeedURL:self.feedURL];
	self.feedParser.delegate = self;
	self.feedParser.feedParseType = ParseTypeItemsOnly;
	self.feedParser.connectionType = ConnectionTypeAsynchronously;
}

- (void)refreshData {
	if (self.shouldDoNothing) return;
	[self.items removeAllObjects];
	[self.tableView reloadData];
	[self.feedParser parse];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	self.detailViewController = segue.destinationViewController;
	self.detailViewController.feedItem = self.items[self.tableView.indexPathForSelectedRow.row];
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
    MWFeedItem *item = self.items[indexPath.row];
	cell.titleLabel.text = item.title.stringByDecodingHTMLEntities;
	cell.textView.text = item.summary.stringByDecodingHTMLEntities;
	if (item.images.count > 0) {
		cell.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
		cell.largeImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.images[0]]]];
	} else {
		cell.largeImageView.image = [UIImage imageNamed:@"Favicon"];
	}
//    cell.detailTextLabel.text = item.summary;
//    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
//    cell.imageView.image = theImage;
    return cell;
}

#pragma mark - NSTableViewDelegate
/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 return 88;
 } //*/
//- table
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.detailViewController.feedItem = self.items[indexPath.row];
	} /*else {
//		JODetailViewController *newViewController = [[JODetailViewController alloc] initWithNibName:@" bundle:<#(NSBundle *)#>
		self.detailViewController.feedItem = self.items[indexPath.row];
		[self.navigationController pushViewController:self.detailViewController animated:YES];
	} //*/
}

#pragma mark - MWFeedParserDelegate
- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed item %@", item);
	
	if ([self.items indexOfObjectPassingTest:^BOOL(MWFeedItem *obj, NSUInteger idx, BOOL *stop) {
		return [obj.date isEqualToDate:item.date] && [obj.title isEqualToString:item.title];
	}] != NSNotFound) {
		NSLog(@"Finished parsing item %@ twice?", item);
		return;
	} //*/
	[self.items addObject:item];
	[self.items sortUsingComparator:^NSComparisonResult(MWFeedItem *obj1, MWFeedItem *obj2) {
		return [obj1.date compare:obj2.date] * -1;
	}];
	NSUInteger newIdx = [self.items indexOfObjectIdenticalTo:item];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIdx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Failed with error %@", error);
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error parsing feed" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started");
}
- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished");
	[self.refreshControl endRefreshing];
}

@end
