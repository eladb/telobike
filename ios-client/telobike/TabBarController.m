//
//  TabBarController.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TabBarController.h"

@implementation TabBarController

@synthesize tabBarControllerDelegate=_tabBarControllerDelegate;

- (void)dealloc
{
    [_visibleTabBar release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"self.view:%@", self.view);
        self.tabBar.hidden = YES;
        _visibleTabBar = [[UITabBar alloc] init];
        _visibleTabBar.delegate = self;
        
        NSMutableArray* items = [NSMutableArray array];
        for (UITabBarItem* item in self.tabBar.items) {
            NSString* localizedTitle = NSLocalizedString(item.title, nil);
            UITabBarItem* newItem = [[[UITabBarItem alloc] initWithTitle:localizedTitle image:item.image tag:0] autorelease];
            [items addObject:newItem];
        }
        [_visibleTabBar setItems:items];
        [_visibleTabBar setFrame:CGRectMake(0, 480 - 49, 320, 49)];
        [[self view] addSubview:_visibleTabBar];
    }
    return self;
}

- (void)setSelectedItemIndex:(NSInteger)index
{
    UITabBarItem* i = [[_visibleTabBar items] objectAtIndex:index];
    [_visibleTabBar setSelectedItem:i];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger i = 0;
    
    for (UITabBarItem* it in _visibleTabBar.items) {
        if (it == item) {
            break;
        }
        i++;
    }
    
    [_tabBarControllerDelegate tabBarController:self didSelectItemAtIndex:i];
}

@end
