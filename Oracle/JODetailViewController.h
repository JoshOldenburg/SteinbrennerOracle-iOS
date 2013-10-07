//
//  JODetailViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

@interface JODetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) id detailItem;
@property (nonatomic, weak) IBOutlet UILabel *detailDescriptionLabel;

@end
