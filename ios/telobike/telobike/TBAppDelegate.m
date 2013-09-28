//
//  TBAppDelegate.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBAppDelegate.h"

@interface TBAppDelegate ()

@end

@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIColor* barTint = [UIColor blackColor];
    UIColor* tint = [UIColor whiteColor];

    // if this is iOS 7, set theme
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"7."]) {
        [UITabBar appearance].barTintColor = barTint;
        [UINavigationBar appearance].barTintColor = barTint;

        // this will make the status bar text white
        [UIView appearance].tintColor = tint;

        [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName:tint };

        self.window.backgroundColor = [UIColor whiteColor];
    }
    else {
        [UINavigationBar appearance].tintColor = barTint;
    }
    
    return YES;
}
							
@end