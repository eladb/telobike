//
//  TBAppDelegate.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "TBAppDelegate.h"

@interface TBAppDelegate ()

@end

@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyCqwGJK_a2virlkr_NzP5o-GcTK-Dl8eXY"];

//    UIColor* barTint = [UIColor blackColor];
//    UIColor* tint = [UIColor colorWithWhite:0.7 alpha:1.0];
//
//    // if this is iOS 7, set theme
//    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"7."]) {
//        [UITabBar appearance].barTintColor = tint;
//        [UITabBar appearance].tintColor = barTint;
//        [UINavigationBar appearance].barTintColor = barTint;
//
//        // this will make the status bar text white
//        [UIView appearance].tintColor = tint;
//
//
//        self.window.backgroundColor = [UIColor whiteColor];
//    }
//    else {
//        [UINavigationBar appearance].tintColor = barTint;
//    }
//    
    return YES;
}
							
@end