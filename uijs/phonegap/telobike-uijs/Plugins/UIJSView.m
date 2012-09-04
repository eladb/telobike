//
//  UIJSView.m
//  sample
//
//  Created by ELAD BEN-ISRAEL on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SBJson.h>
#import "UIJSView.h"

@implementation UIJSView

@synthesize uijs, objid;

- (void)uijs_init:(NSDictionary*)args
{
    NSLog(@"init: %@", args);
}

- (void)uijs_move:(NSDictionary*)args
{
    CGRect frame = CGRectMake([[args objectForKey:@"x"] floatValue],
                              [[args objectForKey:@"y"] floatValue],
                              [[args objectForKey:@"width"] floatValue],
                              [[args objectForKey:@"height"] floatValue]);
    
    self.frame = frame;
}

- (void)emitEvent:(NSString*)name withObject:(id)object
{
//    NSLog(@"emitting event: %@ with object %@", name, object);
    NSString* js = [NSString stringWithFormat:@"window.uijs_emit_event(\'%@\', '%@', %@)", self.objid, name, [object JSONRepresentation]];
    [self.uijs writeJavascript:js];
}

@end
