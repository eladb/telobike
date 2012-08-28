//
//  UIJSWebView.m
//  telobike-uijs
//
//  Created by ELAD BEN-ISRAEL on 8/28/12.
//
//

#import "UIJSWebView.h"
#import "SBJson.h"

@implementation UIJSWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSDictionary* pt = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:point.x], @"x", [NSNumber numberWithFloat:point.y], @"y", nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:pt, @"pt", nil];
    NSString* script = [NSString stringWithFormat:@"window && window.uijs_hittest && window.uijs_hittest(%@)", [options JSONString]];
//    NSLog(@"script:%@", script);
    NSString* result = [self stringByEvaluatingJavaScriptFromString:script];
    BOOL uijsHit = [result boolValue];
    if (uijsHit) return [super hitTest:point withEvent:event];
    else return nil;
}

@end
