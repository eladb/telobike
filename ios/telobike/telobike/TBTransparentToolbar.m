//
//  TBTransparentToolbar.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/6/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBTransparentToolbar.h"

@implementation TBTransparentToolbar

- (void)drawRect:(CGRect)rect {
    [[UIColor clearColor] set]; // or clearColor etc
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end
