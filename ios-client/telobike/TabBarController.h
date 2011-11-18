//
//  TabBarController.h
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabBarControllerDelegate;

@interface TabBarController : UITabBarController <UITabBarDelegate>
{
    UITabBar* _visibleTabBar;
}

@property (nonatomic, assign) id<TabBarControllerDelegate> tabBarControllerDelegate;

- (void)setSelectedItemIndex:(NSInteger)index;

@end

@protocol TabBarControllerDelegate <NSObject>

@required

- (void)tabBarController:(TabBarController*)tabBarController didSelectItemAtIndex:(NSInteger)index;

@end