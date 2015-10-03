//
//  JOAppDelegate.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOAppDelegate.h"
#import "JOMasterViewController.h"

@implementation JOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
	    UINavigationController *navigationController = splitViewController.viewControllers.lastObject;
	    splitViewController.delegate = (id)navigationController.topViewController;
	}
	
    return YES;
}

@end
