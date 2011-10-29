//
//  telobikeAppDelegate.h
//  telobike
//
//  Created by eladb on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RootViewController.h"
#import "MapViewController.h"

extern NSString* const kLocationChangedNotification;

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, RootViewControllerDelegate, MapViewControllerDelegate> 
{
    CLLocationManager* _locationManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *mainController;
@property (nonatomic, readonly) CLLocation* currentLocation;

@property (nonatomic, readonly) RootViewController* listView;
@property (nonatomic, readonly) MapViewController* mapView;

+ (AppDelegate*)app;

- (void)addLocationChangeObserver:(id)target selector:(SEL)selector;
- (void)removeLocationChangeObserver:(id)target;

@end
