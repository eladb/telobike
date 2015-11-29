//
//  UIViewController+GAI.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/14/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

#import "UIViewController+GAI.h"

@implementation UIViewController (GAI)

- (void)analyticsScreenDidAppear:(NSString*)screenName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end
