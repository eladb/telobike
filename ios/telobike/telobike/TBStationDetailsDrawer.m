//
//  TBStationDetailsDrawer.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/11/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationDetailsDrawer.h"

@implementation TBStationDetailsDrawer

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGFloat lineWidth = 280.0f;

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetWidth(rect) / 2.0 - lineWidth / 2.0, CGRectGetMidY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetWidth(rect) / 2.0 + lineWidth / 2.0, CGRectGetMidY(rect));
    CGContextSetLineWidth(ctx, 0.5f);
    [[UIColor colorWithWhite:0.7f alpha:0.8f] set];
    CGContextStrokePath(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetWidth(rect) / 2.0 - lineWidth / 2.0, CGRectGetMidY(rect) + 1);
    CGContextAddLineToPoint(ctx, CGRectGetWidth(rect) / 2.0 + lineWidth / 2.0, CGRectGetMidY(rect) + 1);
    CGContextSetLineWidth(ctx, 0.5f);
    [[UIColor colorWithWhite:1.0f alpha:1.0f] set];
    CGContextStrokePath(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, rect.size.width, CGRectGetMaxY(rect));
    CGContextSetLineWidth(ctx, 0.5f);
    [[UIColor colorWithWhite:0.5f alpha:0.8f] set];
    CGContextStrokePath(ctx);

    CGContextRestoreGState(ctx);
}

@end
