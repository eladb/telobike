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
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.station) {
        return; // nothing to do if we don't have a station set
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGFloat spacing = 3.5f;
    long totalSlots = self.station.availSpace + self.station.availBike;
//    CGFloat slotWidth = 8.0f;//;rect.size.width / totalSlots - spacing;
    CGFloat slotSize = rect.size.height - spacing;//9.0f;//;rect.size.width / totalSlots - spacing;
    CGFloat startX = 1.0f;
    CGFloat startY = rect.size.height / 2.0f - slotSize / 2.0f + 1.0f;
    CGFloat x = startX;
    CGFloat y = startY;
    
    
    CGFloat maxSlots = rect.size.width / (slotSize + spacing);

    NSInteger availSpace = self.station.availSpace;
    NSInteger availBike = self.station.availBike;
    
    NSInteger percentageThreshold = 10.0f;
    
    // if we have more slots that we can display we do not display
    // the discrete number but rather percentage. however, we want to
    // do this only in case we have *enough* bike/spaces. this is because
    // users can discern a small amount with a quick look but not a large
    // amount (10 in our case).
    if (totalSlots > maxSlots) {

        // use percentage in case we have enough bike/spaces
        if (availBike > percentageThreshold && availSpace > percentageThreshold) {
            availBike = ((float)availBike / totalSlots) * maxSlots;
        }
        
        // in case we have a small number of bike/spaces we would like
        // to show the exact number. for bike, availBike will already
        // be that number. for availSpace, we translate it to bike.
        if (availSpace <= percentageThreshold) {
            availBike = maxSlots - availSpace;
        }
        
        totalSlots = maxSlots;
    }
    
    UIColor* fullSlotColor = self.station.fullSlotColor;
    UIColor* emptySlotColor = self.station.emptySlotColor;

    for (int i = 0; i < totalSlots; ++i) {
        if (i < availBike) {
            CGContextSetLineWidth(ctx, 1.0f);
            CGContextSetStrokeColorWithColor(ctx, [fullSlotColor CGColor]);
            CGContextSetFillColorWithColor(ctx, [fullSlotColor CGColor]);
        }
        else {
            CGContextSetLineWidth(ctx, 1.0f);
            CGContextSetStrokeColorWithColor(ctx, [emptySlotColor CGColor]);
            CGContextSetFillColorWithColor(ctx, [[UIColor clearColor] CGColor]);
        }

        CGRect slotRect = CGRectMake(x, y, slotSize, slotSize);
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:slotRect cornerRadius:slotRect.size.width / 2.0f];
        [path fill];
        [path stroke];

        x += slotSize + spacing;
        if (x + slotSize > rect.size.width) {
            x = startX;
            y += slotSize + spacing;
        }
    }
}

@end
