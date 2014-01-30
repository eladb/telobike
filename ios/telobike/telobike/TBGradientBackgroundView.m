//
//  TBGradientBackgroundView.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/11/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBGradientBackgroundView.h"

@implementation TBGradientBackgroundView

- (void)drawRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray* gradientColors = @[ (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor],
                                 (id)[[UIColor colorWithWhite:0.0f alpha:0.3f] CGColor] ];
    
    CGFloat gradientLocations[] = { 0.0f, 1.0f };
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, gradientLocations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
}

@end
