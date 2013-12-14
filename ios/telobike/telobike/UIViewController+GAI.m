//
//  UIViewController+GAI.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/14/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import "UIViewController+GAI.h"

@implementation UIViewController (GAI)

- (void)analyticsScreenDidAppear:(NSString*)screenName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
