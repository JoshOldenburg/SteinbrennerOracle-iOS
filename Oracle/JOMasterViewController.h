//
//  JOMasterViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JODetailViewController;

@interface JOMasterViewController : UITableViewController

@property (strong, nonatomic) JODetailViewController *detailViewController;

@end
