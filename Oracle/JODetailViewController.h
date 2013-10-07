//
//  JODetailViewController.h
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JODetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
