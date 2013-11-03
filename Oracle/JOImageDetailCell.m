//
//  JOImageDetailElement.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/7/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JOImageDetailCell.h"

@implementation JOImageDetailCell

- (void)prepareForReuse {
	[super prepareForReuse];
	self.largeImageView.image = nil;
	self.titleLabel.text = nil;
	self.blurbLabel.text = nil;
}

@end
