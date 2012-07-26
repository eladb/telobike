//
//  MKMapViewWithTouch.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKMapViewWithTouch.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface GestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) id<GestureRecognizerProxy> proxy;

@end

@implementation GestureRecognizer

@synthesize proxy;

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.cancelsTouchesInView = NO;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [proxy touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [proxy touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end

@implementation MKMapViewWithTouch

@synthesize touchDelegate;

- (void)initialize
{
    GestureRecognizer* t = [[GestureRecognizer alloc] init];
    t.proxy = self;
    [self addGestureRecognizer:t];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self touchDelegate] mapViewWillMove:self];
}

@end
