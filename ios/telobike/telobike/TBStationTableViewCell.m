//
//  TBStationTableViewCell.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationTableViewCell.h"

@interface TBStationTableViewCell ()

//@property (strong, nonatomic) IBOutlet UIImageView* iconImageView;
//@property (strong, nonatomic) IBOutlet UILabel*     stationNameLabel;
//@property (strong, nonatomic) IBOutlet UILabel*     availableBikesLabel;
//@property (strong, nonatomic) IBOutlet UILabel*     availableSlotsLabel;
//@property (strong, nonatomic) IBOutlet UILabel*     distanceLabel;
//
//
@end

@implementation TBStationTableViewCell

- (void)setStation:(TBStation *)station
{
    self.imageView.image      = station.listImage;
    self.textLabel.text       = station.stationName;
    
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] init];
    [desc appendAttributedString:[[NSAttributedString alloc] initWithString:station.availBikeDesc  attributes:@{ NSForegroundColorAttributeName: station.availBikeColor }]];
    [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@" ・ "]];
    [desc appendAttributedString:[[NSAttributedString alloc] initWithString:station.availSpaceDesc attributes:@{ NSForegroundColorAttributeName: station.availSpaceColor }]];
    self.detailTextLabel.attributedText = desc;
    _station = station;
}

@end
