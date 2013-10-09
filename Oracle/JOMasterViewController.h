//
//  JOMasterViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@class JODetailViewController;

@interface JOMasterViewController : UITableViewController

@property (nonatomic, strong) IBOutlet JODetailViewController *detailViewController;
@property (nonatomic, strong) NSURL *feedURL;

@end
