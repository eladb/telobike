//
//  TBStationAnnotationView.m
//  telobike
//
//  Created by Elad Ben-Israel on 10/15/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationAnnotationView.h"
#import "TBStation.h"

static CGFloat kDeselectedSize = 24.0f;
static CGFloat kSelectedSize = 48.0f;

@implementation TBStationAnnotationView

- (TBStation*)station {
    return (TBStation*)self.annotation;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    CGRect startBounds = CGRectZero;
    CGRect endBounds = CGRectZero;
    
    if (selected) {
        startBounds.size = CGSizeMake(kDeselectedSize, kDeselectedSize);
        endBounds.size = CGSizeMake(kSelectedSize, kSelectedSize);
    }
    else {
        startBounds.size = CGSizeMake(kSelectedSize, kSelectedSize);
        endBounds.size = CGSizeMake(kDeselectedSize, kDeselectedSize);
    }
    
    if (animated) {
        CABasicAnimation* a = [CABasicAnimation animationWithKeyPath:@"bounds"];
        a.fromValue = [NSValue valueWithCGRect:startBounds];
        a.toValue = [NSValue valueWithCGRect:endBounds];
        a.duration = 0.25f;
        a.removedOnCompletion = NO;
        a.fillMode = kCAFillModeForwards;
        a.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.layer addAnimation:a forKey:@"B"];
    }
    else {
        self.layer.bounds = endBounds;
        [self.layer removeAllAnimations];
    }
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    self.layer.contents = (id)[self.station.selectedMarkerImage CGImage];
    self.layer.bounds = CGRectMake(0, 0, kDeselectedSize, kDeselectedSize);
}

@end
