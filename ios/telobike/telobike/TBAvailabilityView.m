//
//  TBAvailabilityView.m
//  telobike
//
//  Created by Elad Ben-Israel on 10/3/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBAvailabilityView.h"

@implementation TBAvailabilityView

- (void)setStation:(TBStation *)station {
    _station = station;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.station) {
        return; // nothing to do if we don't have a station set
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGFloat spacing = 4.0f;
    int totalSlots = self.station.availSpace + self.station.availBike;
//    CGFloat slotWidth = 8.0f;//;rect.size.width / totalSlots - spacing;
    CGFloat slotWidth = 8.0f;//;rect.size.width / totalSlots - spacing;
    CGFloat startX = 1.0f;
    CGFloat startY = rect.size.height / 2.0f - slotWidth / 2.0f + 1.0f;
    CGFloat x = startX;
    CGFloat y = startY;
    for (int i = 0; i < totalSlots; ++i) {
        if (i < self.station.availBike) {
            UIColor* slotColor = self.station.availBikeColor;
//            UIColor* slotColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
            CGContextSetLineWidth(ctx, 1.0f);
            CGContextSetStrokeColorWithColor(ctx, [slotColor CGColor]);
            CGContextSetFillColorWithColor(ctx, [slotColor CGColor]);
        }
        else {
            UIColor* slotColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
//            UIColor* slotColor = self.station.availSpaceColor;
            CGContextSetLineWidth(ctx, 1.0f);
            CGContextSetStrokeColorWithColor(ctx, [slotColor CGColor]);
            CGContextSetFillColorWithColor(ctx, [[UIColor clearColor] CGColor]);
        }

        CGRect slotRect = CGRectMake(x, y, slotWidth, slotWidth);
//        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:slotRect cornerRadius:slotRect.size.width / 2.0f];
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:slotRect cornerRadius:1.0f];
        [path fill];
        [path stroke];

        x += slotWidth + spacing;
        if (x + slotWidth > rect.size.width) {
            x = startX;
            y += slotWidth + spacing;
        }
    }
}

@end
