//
//  TBAppDelegate.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Appirater.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>

#import "TBAppDelegate.h"
#import "TBServer.h"

@interface TBAppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;

@end

@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // rate app
    [Appirater setAppId:@"436915919"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];

    // location alert
    [self alertOnLocationServicesDisabled];
    
    // analytics
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-27122332-1"];

    // push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    [Appirater appLaunched:YES];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveLocalNotification" object:notification];
}

#pragma mark - Location services alert

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

#pragma mark - Push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"device token: %@", deviceTokenString);
    
    [[TBServer instance] postPushToken:deviceTokenString completion:^{
        NSLog(@"push token posted");
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary* aps = userInfo[@"aps"];
    NSString* alert = aps[@"alert"];
    
    if (alert) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", nil) message:alert delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

@end