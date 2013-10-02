//
//  TBStationDetailsView.m
//  telobike
//
//  Created by Elad Ben-Israel on 10/2/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationDetailsView.h"
#import "UIColor+Style.h"

@interface TBStationDetailsView()

@property (strong, nonatomic) IBOutlet UIView* parkingContainerView;
@property (strong, nonatomic) IBOutlet UIView* bikeContainerView;

@property (strong, nonatomic) IBOutlet UILabel* availSpaceLabel;
@property (strong, nonatomic) IBOutlet UILabel* availBikeLabel;

@property (strong, nonatomic) IBOutlet UILabel* stationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* stationAddressLabel;

@end

@implementation TBStationDetailsView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.barTintColor = [UIColor detailsBackgroundColor];
}

- (void)setStation:(TBStation *)station {
    _station = station;
    
    self.availSpaceLabel.text = [NSString stringWithFormat:@"%ld", (long)station.availSpace];
    self.availBikeLabel.text = [NSString stringWithFormat:@"%ld", (long)station.availBike];
    
    self.parkingContainerView.layer.cornerRadius = 5.0f;
    self.bikeContainerView.layer.cornerRadius = 5.0f;
    
    self.parkingContainerView.backgroundColor = station.availSpaceColor;
    self.bikeContainerView.backgroundColor = station.availBikeColor;
    
    self.stationNameLabel.text = station.stationName;
    self.stationAddressLabel.text = station.address;
}

@end
