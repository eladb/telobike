//
//  TBGradientView.m
//  telobike
//
//  Created by Elad Ben-Israel on 10/4/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBTintedView.h"

@implementation TBTintedView

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [self.fillColor CGColor]);
    UIRectFill(rect);
//    
//
//    
//    CGColorRef startColor = [self.fillColor CGColor];
//    CGColorRef endColor = [self.backgroundColor CGColor];
//
//    if (!endColor) {
//        endColor = [[UIColor whiteColor] CGColor];
//    }
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    if (!self.fillColor || self.fillColor == self.backgroundColor) {
//        CGContextSetFillColorWithColor(ctx, endColor);
//        UIRectFill(rect);
//        return;
//    }
//    
//    CGContextBeginPath(ctx);
//    CGContextAddRect(ctx, rect);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGFloat locations[] = { 0.0, 1.0 };
//    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
//    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
//
//    CGPoint startPoint = CGPointMake(0.0f, CGRectGetMidY(rect));
//    CGPoint endPoint = CGPointMake(rect.size.width, startPoint.y);
//    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
//
//    CGGradientRelease(gradient);
//    CGColorSpaceRelease(colorSpace);
}

@end
