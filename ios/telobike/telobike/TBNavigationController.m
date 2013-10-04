//
//  TBNavigationController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBNavigationController.h"
#import "UIColor+Style.h"

static const NSUInteger kTabBarHeight = 49.0f;

@interface TBNavigationController () <UITabBarDelegate>

@property (strong, nonatomic) UITabBar* tabBar;

@property (strong, nonatomic) TBMapViewController*      mapViewController;
@property (strong, nonatomic) TBListViewController*     listViewController;
@property (strong, nonatomic) TBTimerViewController*    timerViewController;
@property (strong, nonatomic) TBSettingsViewController* settingsViewController;

@end

@implementation TBNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listViewController = [self.viewControllers objectAtIndex:0];
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    self.timerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"timer"];
    
    self.settingsViewController = [[TBSettingsViewController alloc] init];
    
    // add tabbar to navigation controller so it will be visible everywhere
    CGRect tabBarFrame;
    tabBarFrame.origin = CGPointMake(0.0f, self.view.frame.size.height - kTabBarHeight);
    tabBarFrame.size   = CGSizeMake(self.view.frame.size.width, kTabBarHeight);
    self.tabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    self.tabBar.itemSpacing = 0.5f;


    NSMutableArray* items = [[NSMutableArray alloc] init];
    [items addObject:self.listViewController.tabBarItem];
    [items addObject:self.mapViewController.tabBarItem];
    [items addObject:self.timerViewController.tabBarItem];
//    [items addObject:self.settingsViewController.tabBarItem];
    
    self.tabBar.items = items;
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    self.tabBar.delegate = self;
    self.tabBar.barTintColor = [UIColor tabbarBackgroundColor];
    self.tabBar.tintColor    = [UIColor tabbarTintColor];
    
    [self.view addSubview:self.tabBar];

    // theme navigation bar
    self.navigationBar.barTintColor        = [UIColor navigationBarBackgroundColor];
    self.navigationBar.tintColor           = [UIColor navigationBarTintColor];
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor navigationBarTitleColor] };
}

#pragma mark - Tab bar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == self.mapViewController.tabBarItem) {
        if (self.topViewController == self.mapViewController) {
            return;
        }
        
        self.viewControllers = @[ self.listViewController ];
        [self pushViewController:self.mapViewController animated:NO];
        return;
    }
    
    if (item == self.listViewController.tabBarItem) {
        self.viewControllers = @[ self.listViewController ];
        return;
    }
    
    if (item == self.timerViewController.tabBarItem) {
        self.viewControllers = @[ self.timerViewController ];
        return;
    }
    
    if (item == self.settingsViewController.tabBarItem) {
        self.viewControllers = @ [ self.settingsViewController ];
        return;
    }
}

@end
