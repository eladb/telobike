//
//  TBSearchViewController.h
//  telobike
//
//  Created by Elad Ben-Israel on 12/9/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TBMapViewController.h"
#import "TBListViewController.h"
#import "TBMainViewController.h"

@interface TBMainViewController : UIViewController

@property (readonly, nonatomic) TBListViewController* nearByViewController;
@property (readonly, nonatomic) TBListViewController* favoritesViewController;
@property (readonly, nonatomic) TBMapViewController* mapViewController;

@property (readonly, nonatomic) UITabBar* tabBar;

@end

@interface UIViewController (TB)

- (TBMainViewController*)main;

@end