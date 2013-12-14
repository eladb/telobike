//
//  TBAppDelegate.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Appirater.h>
#import "TBAppDelegate.h"

@interface TBAppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;

@end

@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Appirater setAppId:@"436915919"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];

    [self alertOnLocationServicesDisabled];

    [Appirater appLaunched:YES];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveLocalNotification" object:notification];
}

- (void)alertOnLocationServicesDisabled {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    
    if (error.code == kCLErrorDenied) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Services Disabled for Telobike", Nil)
                                    message:NSLocalizedString(@"Go to the Settings app and under Privacy -> Location Services, enable Telobike", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }
}

@end