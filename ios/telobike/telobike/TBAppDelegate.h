//
//  TBAppDelegate.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBMapViewController.h"
#import "TBListViewController.h"
#import <RESideMenu/RESideMenu.h>

@interface TBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) RESideMenu* sideMenuController;

@end
