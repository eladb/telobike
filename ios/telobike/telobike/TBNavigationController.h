//
//  TBNavigationController.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMapViewController.h"
#import "TBListViewController.h"
#import "TBTimerViewController.h"
#import "TBSettingsViewController.h"

@interface TBNavigationController : UINavigationController

@property (strong, readonly) UITabBar* tabBar;
@property (strong, readonly) TBListViewController*     nearByViewController;
@property (strong, readonly) TBListViewController*     favoritesViewController;
@property (strong, readonly) TBMapViewController*      mapViewController;
@property (strong, readonly) TBTimerViewController*    timerViewController;
@property (strong, readonly) TBSettingsViewController* settingsViewController;

@end
