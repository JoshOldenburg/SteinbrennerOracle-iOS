//
//  JOMasterViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "QuickDialog.h"
@class JODetailViewController;

@interface JOMasterViewController : QuickDialogController

@property (nonatomic, strong) JODetailViewController *detailViewController;

@end
