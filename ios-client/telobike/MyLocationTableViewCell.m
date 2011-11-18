//
//  MyLocationTableViewCell.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MyLocationTableViewCell.h"

@implementation MyLocationTableViewCell

- (void)dealloc
{
    [currentLocationLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    currentLocationLabel.text = NSLocalizedString(@"Current location", nil);
}

@end
