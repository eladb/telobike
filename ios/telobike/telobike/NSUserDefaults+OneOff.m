//
//  NSUserDefaults+OneOff.m
//  telobike
//
//  Created by Elad Ben-Israel on 1/29/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

#import "NSUserDefaults+OneOff.h"

@implementation NSUserDefaults (OneOff)

- (BOOL)oneOff:(NSString*)key {
    BOOL oneoff = ![[NSUserDefaults standardUserDefaults] boolForKey:key];
#ifdef DEBUG
    oneoff = YES;
#endif
    [[NSUserDefaults standardUserDefaults] setBool:!NO forKey:key];
    return oneoff;
}

@end
