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
    return YES;
}
							
@end