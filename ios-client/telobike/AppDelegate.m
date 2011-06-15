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

NSString* const kLocationChangedNotification = @"kLocationChangedNotification";

@interface AppDelegate (Private)

- (void)downloadCityAndStart;
- (void)showDisclaimerFirstTime;

@end

@implementation AppDelegate

@synthesize window=_window;
@synthesize mainController=_mainController;

- (void)dealloc
{
    [_window release];
    [_mainController release];
    [_locationManager release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    }
    
    LoadingViewController* vc = [[LoadingViewController new] autorelease];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [self downloadCityAndStart];
    
    
    [Appirater appLaunched:YES];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

+ (AppDelegate*)app
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark Location

- (CLLocation*)currentLocation
{
#if TARGET_IPHONE_SIMULATOR
    return [[[CLLocation alloc] initWithLatitude:32.0699 longitude:34.7772] autorelease];
#else   
    return _locationManager.location;
#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangedNotification object:nil];
}

- (void)addLocationChangeObserver:(id)target selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:target selector:selector name:kLocationChangedNotification object:nil];
}

- (void)removeLocationChangeObserver:(id)target
{
    [[NSNotificationCenter defaultCenter] removeObserver:target name:kLocationChangedNotification object:nil];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self downloadCityAndStart];
}

@end

@implementation AppDelegate (Private)

- (void)downloadCityAndStart
{
    void(^failureBlock)(void) = ^
    {
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", nil) 
                                     message:NSLocalizedString(@"NETWORK_ERROR", nil) 
                                    delegate:self 
                           cancelButtonTitle:NSLocalizedString(@"NETWORK_ERROR_BUTTON", nil) 
                           otherButtonTitles:nil] autorelease] show];
    };
    
    [[City instance] refreshWithCompletion:^
     {
         [[StationList instance] refreshStationsWithCompletion:^
          {
              UIViewController* stationsVC = [self.mainController.viewControllers objectAtIndex:0];
              UIViewController* infoVC = [self.mainController.viewControllers objectAtIndex:1];
              IASKAppSettingsViewController* settingsVC = [self.mainController.viewControllers objectAtIndex:2];
              [settingsVC.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
              
              
              stationsVC.navigationItem.title = stationsVC.tabBarItem.title = NSLocalizedString(@"STATIONS_TITLE", nil);
              infoVC.navigationItem.title = infoVC.tabBarItem.title = NSLocalizedString(@"INFO_TITLE", nil);
              settingsVC.navigationItem.title = settingsVC.tabBarItem.title = NSLocalizedString(@"Settings", nil);
              
              [self showDisclaimerFirstTime];
              self.window.rootViewController = self.mainController;
              
              [self.window makeKeyAndVisible];
          } failure:failureBlock useCache:YES];
     } failure:failureBlock useCache:YES];
}

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