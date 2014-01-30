//
//  UIJSTabBar.m
//  telobike-uijs
//
//  Created by ELAD BEN-ISRAEL on 8/28/12.
//
//

#import "UIJSTabBar.h"

@interface UIJSTabBarItem : UITabBarItem

@property (nonatomic, retain) NSString* tabid;
@property (nonatomic, retain) NSDictionary* tab;

@end

@implementation UIJSTabBarItem
@end

@interface UIJSTabBar()
{
    UITabBar* _tabbar;
}
@end

@implementation UIJSTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tabbar = [[UITabBar alloc] initWithFrame:self.bounds];
        _tabbar.delegate = self;
        _tabbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_tabbar];
    }
    return self;
}

- (void)uijs_set_tabs:(NSDictionary*)params
{
    NSArray* tabs = [params objectForKey:@"tabs"];
    NSLog(@"uijs_set_tabs: %@", tabs);
    
    if (!tabs) return;
        
    NSMutableArray* items = [[NSMutableArray alloc] init];

    for (NSDictionary* tab in tabs) {
        NSString* title = [tab objectForKey:@"title"];
        UIJSTabBarItem* item = [[UIJSTabBarItem alloc] initWithTitle:title image:nil tag:0];
        item.image = [self.uijs imageForResource:[tab objectForKey:@"icon"]];
        item.tabid = [tab objectForKey:@"_id"];
        item.tab = tab;
        [items addObject:item];
    }
    
    _tabbar.items = items;
}

- (void)uijs_select_tab:(NSDictionary*)options
{
    NSString* key = [options objectForKey:@"key"];
    NSLog(@"uijs_select_tab: %@", key);
    
    if (!key) return;
    
    for (UIJSTabBarItem* item in _tabbar.items) {
        if ([[item tabid] isEqualToString:key]) {
            _tabbar.selectedItem = item;
            return;
        }
    }
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UIJSTabBarItem* uijsItem = (UIJSTabBarItem*)item;
    NSDictionary* params = [NSDictionary dictionaryWithObject:uijsItem.tabid forKey:@"id"];
    [self emitEvent:@"_selected" withObject:params];
}

@end
