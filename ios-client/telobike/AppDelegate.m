//
//  telobikeAppDelegate.m
//  telobike
//
//  Created by eladb on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
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
@synthesize listView=_listView;
@synthesize mapView=_mapView;

- (void)dealloc
{
    [_mapView release];
    [_listView release];
    [_window release];
    [_mainController release];
    [_locationManager release];
    [_feedbackOptions release];
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
    
    _feedbackOptions = [[FeedbackOptions alloc] init];
    _feedbackOptions.delegate = self;
    
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

#pragma mark Map

- (void)rootViewController:(RootViewController *)viewController didSelectStation:(Station *)station
{
    _mainController.selectedIndex = 1;
    [_mapView selectStation:station];
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

#pragma mark - Map

- (void)mapViewControllerDidSelectList:(MapViewController *)viewController
{
    [self.mainController setSelectedIndex:0];
}

#pragma mark - Feedback

- (void)presentFeedbackViewController
{
    [_feedbackOptions showFromTabBar:_mainController.tabBar];
}

+ (void)showFeedback
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app presentFeedbackViewController];
}

- (void)rootViewControllerDidTouchFeedback:(RootViewController *)viewController
{
    [self presentFeedbackViewController];
}

- (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[self mainController] presentModalViewController:viewController animated:animated];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [[self mainController] dismissModalViewControllerAnimated:animated];
}

#pragma mark - Timer

-(void)playSound:(NSString *)fileName ext:(NSString*)ext
{
    NSURL* pathURL  = [[NSBundle mainBundle] URLForResource:fileName withExtension:ext];
    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // if we came from the background, we don't need an alert because it was already displayed
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }
    
    /* sound attribution:
     <div xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/" about="http://soundcloud.com/soundbyterfreesounds/www-soundbyter-com-bicycle-bell-sound-effect"><span property="dct:title">"www.soundbyter.com-bicycle-bell-sound-effect"</span> (<a rel="cc:attributionURL" property="cc:attributionName" href="http://soundcloud.com/soundbyterfreesounds">soundbyterfreesounds</a>) / <a rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/">CC BY-NC 3.0</a></div>
     */
    
    NSString* soundName = notification.soundName;
    if (soundName) {
        [self playSound:soundName ext:nil];
    }
    
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", nil) 
                                 message:notification.alertBody delegate:nil 
                       cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                       otherButtonTitles:nil] autorelease] show];
}

- (void)presentInfoViewController
{
    InfoViewController* infoViewController = [[[InfoViewController alloc] init] autorelease];
    infoViewController.delegate = self;
    UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController:infoViewController] autorelease];
    [[self mainController] presentModalViewController:navigationController animated:YES];
}

#pragma mark - Info

+ (void)showInfo
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app presentInfoViewController];
}

- (void)infoViewControllerDidClose:(InfoViewController *)viewController
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[app mainController] dismissModalViewControllerAnimated:YES];
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
              UIViewController* mapVC = [self.mainController.viewControllers objectAtIndex:1];
              UIViewController* alarmVC = [self.mainController.viewControllers objectAtIndex:2];
              IASKAppSettingsViewController* settingsVC = [self.mainController.viewControllers objectAtIndex:3];
              [settingsVC.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
              
              stationsVC.navigationItem.title = stationsVC.tabBarItem.title = NSLocalizedString(@"STATIONS_TITLE", nil);
              mapVC.navigationItem.title = mapVC.tabBarItem.title = NSLocalizedString(@"MAP_TITLE", nil);
              alarmVC.navigationItem.title = alarmVC.tabBarItem.title = NSLocalizedString(@"TIMER_TITLE", nil);
              settingsVC.navigationItem.title = settingsVC.tabBarItem.title = NSLocalizedString(@"Settings", nil);
              
              [self showDisclaimerFirstTime];
              self.window.rootViewController = self.mainController;
            
              UINavigationController* nav = [[self.mainController viewControllers] objectAtIndex:0];
              _listView = (RootViewController*) [[nav topViewController] retain];
              _listView.delegate = self;
              
              nav = [[self.mainController viewControllers] objectAtIndex:1];
              _mapView = (MapViewController*) [[nav topViewController] retain];
              _mapView.delegate = self;
            
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