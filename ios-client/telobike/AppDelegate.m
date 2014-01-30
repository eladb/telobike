//
//  telobikeAppDelegate.m
//  telobike
//
//  Created by eladb on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "StationList.h"
#import "City.h"
#import "LoadingVC.h"
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
@synthesize favorites=_favorites;

- (void)dealloc
{
    [_mapView release];
    [_listView release];
    [_window release];
    [_mainController release];
    [_locationManager release];
    [_feedbackOptions release];
    [_favorites release];
    [super dealloc];
}

#pragma mark - App Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[Analytics shared] startTracker];
    [[Analytics shared] eventAppStart];
    
    
    
    return YES;
    
    UIColor* barTint = [UIColor blackColor];
    UIColor* tint = [UIColor whiteColor];
    [[UITabBar appearance] setTintColor:tint];
    [[UITabBar appearance] setBarTintColor:barTint];
    [[UINavigationBar appearance] setBarTintColor:barTint];
    [[UINavigationBar appearance] setTintColor:tint];
    [[UIView appearance] setTintColor:tint];
    
    _favorites = [[Favorites alloc] init];
    
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    }
    
    _feedbackOptions = [[FeedbackOptions alloc] init];
    _feedbackOptions.delegate = self;
    
    LoadingVC* vc = [[LoadingVC new] autorelease];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [self downloadCityAndStart];
    
    [Appirater appLaunched:YES];
  
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];

    self.mainController.tabBarControllerDelegate = self;

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    
    [_listView refreshStations:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [_locationManager startUpdatingLocation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [_locationManager stopUpdatingLocation];
}

+ (AppDelegate*)app
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - List

- (void)rootViewController:(RootViewController *)viewController didSelectStation:(Station *)station
{
    [viewController.navigationController pushViewController:_mapView animated:YES];
    [_mapView selectStation:station];
    [_mainController setSelectedItemIndex:1];
}

- (void)rootViewControllerWillAppear:(RootViewController*)viewController
{
    [_mainController setSelectedItemIndex:0];
}

#pragma mark - Map


- (void)mapViewControllerDidSelectList:(MapViewController *)viewController
{
    [self.mainController setSelectedIndex:0];
}

#pragma mark - Location

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
    [[self mainController] presentViewController:viewController animated:animated completion:nil];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [[self mainController] dismissViewControllerAnimated:animated completion:nil];
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
    navigationController.navigationBar.tintColor = _mapView.navigationController.navigationBar.tintColor;
    [[self mainController] presentViewController:navigationController animated:YES completion:nil];
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
    [[app mainController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // send token to server

    NSString* token = [[[[deviceToken description] 
                         stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                         stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"push token: %@", token);
    NSString* url = [NSString stringWithFormat:@"https://go.urbanairship.com/api/device_tokens/%@", token];
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [req setRequestMethod:@"PUT"];
    [req setUsername:@"yM20oMODRqC8BqFJYhs0Gw"];
    [req setPassword:@"ToeYI9csTJiI00w95uOMsw"];
    [req startAsynchronous];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"push recieved: %@", userInfo);
    NSString* url = [[userInfo objectForKey:@"aps"] objectForKey:@"url"];
    if (url) {
        [application openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark - Tab bar

- (void)tabBarController:(TabBarController *)tabBarController didSelectItemAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [[_listView navigationController] popToRootViewControllerAnimated:NO];
            [_mainController setSelectedIndex:0];
            break;

        case 1:
            [[_listView navigationController] popToRootViewControllerAnimated:NO];
            [[_listView navigationController] pushViewController:_mapView animated:NO];
            [_mainController setSelectedIndex:0];
            break;
            
        case 2:
        case 3:
            [_mainController setSelectedIndex:index];
            break;
            
        default:
            break;
    }
}

@end

#pragma mark -

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
              UINavigationController* settingsVC = [self.mainController.viewControllers objectAtIndex:3];
              IASKAppSettingsViewController* svc = (IASKAppSettingsViewController*) [settingsVC topViewController];
              svc.showCreditsFooter = NO;
              
              stationsVC.navigationItem.title = stationsVC.tabBarItem.title = NSLocalizedString(@"List", nil);
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
    
    NSString* currentDisclaimer = [d objectForKey:@"disclaimer_text"];
    
    NSString* disclaimerMessage = [[City instance] disclaimer];
    if (!disclaimerMessage || disclaimerMessage.length == 0) return;
    disclaimerMessage = [disclaimerMessage stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];

    // if we have already shown this, break
    if ([disclaimerMessage isEqualToString:currentDisclaimer]) return;
    // display the disclaimer and store so we won't display it again.
    [[[[UIAlertView alloc] initWithTitle:nil message:disclaimerMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
    [d setValue:disclaimerMessage forKey:@"disclaimer_text"];
    [d synchronize];
}

@end