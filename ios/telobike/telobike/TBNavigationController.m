//
//  TBNavigationController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBNavigationController.h"

static const NSUInteger kTabBarHeight = 49.0f;

@interface TBNavigationController () <UITabBarDelegate>

@property (strong, nonatomic) UITabBar* tabBar;

@property (strong, nonatomic) TBMapViewController*  mapViewController;
@property (strong, nonatomic) TBListViewController* listViewController;

@end

@implementation TBNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@", self.viewControllers);
    
    self.listViewController = [self.viewControllers objectAtIndex:0];
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    
    // add tabbar to navigation controller so it will be visible everywhere
    CGRect tabBarFrame;
    tabBarFrame.origin = CGPointMake(0.0f, self.view.frame.size.height - kTabBarHeight);
    tabBarFrame.size   = CGSizeMake(self.view.frame.size.width, kTabBarHeight);
    self.tabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    self.tabBar.items = @[ self.listViewController.tabBarItem, self.mapViewController.tabBarItem ];
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    self.tabBar.delegate = self;
    
    [self.view addSubview:self.tabBar];
}

#pragma mark - Tab bar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == self.mapViewController.tabBarItem) {
        if (self.topViewController == self.mapViewController) {
            return;
        }
        
        [self pushViewController:self.mapViewController animated:NO];
        return;
    }
    
    if (item == self.listViewController.tabBarItem) {
        [self popToViewController:self.listViewController animated:NO];
        return;
    }
}

@end
