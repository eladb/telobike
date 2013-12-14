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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveLocalNotification" object:notification];
}

@end