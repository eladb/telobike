//
//  TBSettingsViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBSettingsViewController.h"

@interface TBSettingsViewController ()

@end

@implementation TBSettingsViewController

- (id)init {
    self = [super init];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"settings tabbar title") image:[UIImage imageNamed:@"tabbar-gear"] tag:0];
        self.showCreditsFooter = NO;
        self.showDoneButton = NO;
    }
    return self;
}

@end
