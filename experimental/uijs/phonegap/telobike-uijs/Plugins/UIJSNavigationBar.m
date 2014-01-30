//
//  UIJSTitleBar.m
//  telobike-uijs
//
//  Created by ELAD BEN-ISRAEL on 8/28/12.
//
//

#import "UIJSNavigationBar.h"

@interface UIJSNavigationItem : UINavigationItem

@property (nonatomic, retain) NSDictionary* item;

@end

@implementation UIJSNavigationItem
@end

@interface UIJSNavigationBar()
{
    UINavigationBar* _navbar;
}
@end

@implementation UIJSNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _navbar = [[UINavigationBar alloc] initWithFrame:self.bounds];
        _navbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _navbar.delegate = self;
        [self addSubview:_navbar];
    }
    
    return self;
}

- (void)uijs_push_item:(NSDictionary*)itemAndOptions
{
    NSDictionary* item = [itemAndOptions objectForKey:@"item"];
    NSDictionary* options = [itemAndOptions objectForKey:@"options"];
    NSNumber* animatedValue = [options objectForKey:@"animated"];
    BOOL animated = animatedValue ? [animatedValue boolValue] : YES;
    NSString* title = [item objectForKey:@"title"];
    UIJSNavigationItem* navitem = [[UIJSNavigationItem alloc] initWithTitle:title];
    navitem.item = item;
    [_navbar pushNavigationItem:navitem animated:animated];
}

- (void)uijs_pop_item:(NSDictionary*)options
{
    NSNumber* animatedValue = [options objectForKey:@"animated"];
    BOOL animated = animatedValue ? [animatedValue boolValue] : YES;
    [_navbar popNavigationItemAnimated:animated];
}

- (void)uijs_clear_items:(id)n
{
    _navbar.items = nil;
}

#pragma mark - UINavigationBarDelegate

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    UIJSNavigationItem* navitem = (UIJSNavigationItem*)item;
    [self emitEvent:@"pop" withObject:navitem.item];
}

@end