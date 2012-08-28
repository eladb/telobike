//
//  UIJSMap.m
//  sample
//
//  Created by ELAD BEN-ISRAEL on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIJSNative.h"
#import "UIJSView.h"
#import "SBJson.h"
#import <Cordova/CDV.h>

@interface TouchView : UIView

@end

@implementation TouchView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

@end

@interface UIJSNative ()
{
    NSMutableDictionary* objects;
}

@end

@implementation UIJSNative

- (NSString *)pathForResource:(NSString *)relativePath
{
    CDVViewController* vc = (CDVViewController*) self.viewController;
    return [[NSBundle mainBundle] pathForResource:relativePath ofType:@"" inDirectory:[vc wwwFolderName]];
}

- (UIImage*)imageForResource:(NSString*)relativePath
{
    return [UIImage imageWithContentsOfFile:[self pathForResource:relativePath]];
}

- (void)ensureTouchView {
    const NSInteger TOUCH_VIEW_TAG = 0x1234;
    UIView* parent = [self.webView superview];
    TouchView* tv = (TouchView*)[parent viewWithTag:TOUCH_VIEW_TAG];
    if (!tv) {
        tv = [[TouchView alloc] initWithFrame:parent.bounds];
        tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [parent addSubview:tv];
    }
    
    [parent bringSubviewToFront:tv];
}

- (void)invoke:(NSArray*)args withDict:(NSDictionary*)adict
{
    NSLog(@"HERE!");

    if (!objects) {
        objects = [[NSMutableDictionary alloc] init];
    }
    
    
    NSString* objmethod = [args objectAtIndex:1];
    NSString* objtype = [args objectAtIndex:2];
    NSString* objid = [args objectAtIndex:3];
    id methodargs = [[args objectAtIndex:4] JSONValue];

    NSLog(@"THERE");

    NSLog(@"uijs native invoke %@, %@, %@", objmethod, objtype, objid);

    if (!objid || !objtype || !objmethod) {
        assert(false);
    }
    
    UIJSView* obj = [objects objectForKey:objid];
    if (!obj) {
        Class cls = NSClassFromString(objtype);
        id initializedObj = [[cls alloc] init];
        obj = (UIJSView*)initializedObj;
        obj.objid = objid;
        obj.uijs = self;

        obj.backgroundColor = [UIColor greenColor];
        [[self.webView superview] addSubview:obj];
        [[self.webView superview] bringSubviewToFront:self.webView];
        
//        self.webView.userInteractionEnabled = NO;
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor clearColor];
        [objects setObject:obj forKey:objid];
        
        [self ensureTouchView];
    }
    
    NSString* selectorString = [NSString stringWithFormat:@"uijs_%@:", objmethod];
    SEL selector = NSSelectorFromString(selectorString);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [obj performSelector:selector withObject:methodargs];
#pragma clang diagnostic pop

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self success:result callbackId:[args objectAtIndex:0]];    
}

@end