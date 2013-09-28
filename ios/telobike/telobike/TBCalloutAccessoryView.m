//
//  TBCalloutAccessoryView.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TBCalloutAccessoryView.h"

@interface TBCalloutAccessoryView ()

@property (strong, nonatomic) IBOutlet UIView* parkingContainerView;
@property (strong, nonatomic) IBOutlet UIView* bikeContainerView;

@property (strong, nonatomic) IBOutlet UILabel* availSpaceLabel;
@property (strong, nonatomic) IBOutlet UILabel* availBikeLabel;

@end

@implementation TBCalloutAccessoryView

- (void)setStation:(TBStation *)station {
    _station = station;
    self.availSpaceLabel.text = [NSString stringWithFormat:@"%d", station.availSpace];
    self.availBikeLabel.text = [NSString stringWithFormat:@"%d", station.availBike];
    
    self.parkingContainerView.layer.cornerRadius = 5.0f;
    self.bikeContainerView.layer.cornerRadius = 5.0f;
    
    self.parkingContainerView.backgroundColor = station.availSpaceColor;
    self.bikeContainerView.backgroundColor = station.availBikeColor;
}

@end
