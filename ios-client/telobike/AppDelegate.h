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
#import "InfoViewController.h"
#import "FeedbackOptions.h"
#import "Favorites.h"
#import "Analytics.h"
#import "TabBarController.h"

extern NSString* const kLocationChangedNotification;

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, RootViewControllerDelegate, MapViewControllerDelegate, InfoViewControllerDelegate, FeedbackOptionsDelegate, TabBarControllerDelegate> 
{
    CLLocationManager* _locationManager;
    FeedbackOptions* _feedbackOptions;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TabBarController *mainController;
@property (nonatomic, readonly) CLLocation* currentLocation;

@property (nonatomic, readonly) RootViewController* listView;
@property (nonatomic, readonly) MapViewController* mapView;
@property (nonatomic, readonly) Favorites* favorites;

+ (AppDelegate*)app;

- (void)addLocationChangeObserver:(id)target selector:(SEL)selector;
- (void)removeLocationChangeObserver:(id)target;

// called by the settings page
+ (void)showInfo;
+ (void)showFeedback;

@end
