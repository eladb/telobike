//
//  TBStationTableViewCell.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TBStationTableViewCell.h"
#import "TBAvailabilityView.h"
#import "TBTintedView.h"

@interface TBStationTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel* stationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* subtitleLabel;
@property (strong, nonatomic) IBOutlet TBAvailabilityView* availabilityView;
@property (strong, nonatomic) IBOutlet TBTintedView* availabilityIndicatorView;

@end

@implementation TBStationTableViewCell

- (void)setStation:(TBStation *)station
{
    self.availabilityView.station = station;
    self.stationNameLabel.text    = station.stationName;
    
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] init];
//    if (station.address) {
//        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:station.address attributes:@{ NSForegroundColorAttributeName: [UIColor grayColor] }]];
//    }
//    
//    if (desc.length > 0) {
//        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@"・" attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor] }]];
//    }

    NSString* distance = @"122m";
    [desc appendAttributedString:[[NSAttributedString alloc] initWithString:distance attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor] }]];
    self.subtitleLabel.attributedText = desc;
    self.availabilityIndicatorView.fillColor = station.indicatorColor;

    _station = station;
}

@end
