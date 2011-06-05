//
//  telobikeAppDelegate.m
//  telobike
//
//  Created by eladb on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "StationList.h"
#import "City.h"
#import "LoadingViewController.h"
#import "IASKAppSettingsViewController.h"
#import "Appirater.h"

@interface AppDelegate (Private)

- (void)showDisclaimerFirstTime;

@end

@implementation AppDelegate


@synthesize window=_window;

@synthesize mainController=_mainController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LoadingViewController* vc = [[LoadingViewController new] autorelease];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [[City instance] refreshWithCompletion:^
     {
         [[StationList instance] refreshStationsWithCompletion:^
         {
             UIViewController* stationsVC = [self.mainController.viewControllers objectAtIndex:0];
             UIViewController* infoVC = [self.mainController.viewControllers objectAtIndex:1];
             IASKAppSettingsViewController* settingsVC = [self.mainController.viewControllers objectAtIndex:2];

             stationsVC.navigationItem.title = stationsVC.tabBarItem.title = NSLocalizedString(@"STATIONS_TITLE", nil);
             infoVC.navigationItem.title = infoVC.tabBarItem.title = NSLocalizedString(@"INFO_TITLE", nil);
             settingsVC.navigationItem.title = settingsVC.tabBarItem.title = NSLocalizedString(@"Settings", nil);

             [self showDisclaimerFirstTime];
             self.window.rootViewController = self.mainController;

             [self.window makeKeyAndVisible];
         }];
     }];
    
    [Appirater appLaunched:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_mainController release];
    [super dealloc];
}

+ (AppDelegate*)app
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
@end

@implementation AppDelegate (Private)

- (void)showDisclaimerFirstTime
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    if ([d objectForKey:@"disclaimer"]) return;
    
    NSString* disclaimerMessage = [[City instance] disclaimer];
    [[[[UIAlertView alloc] initWithTitle:nil message:disclaimerMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
    [d setValue:@"Yes" forKey:@"disclaimer"];
    [d synchronize];
}

@end