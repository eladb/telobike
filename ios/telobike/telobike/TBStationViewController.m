//
//  TBStationViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationViewController.h"
#import "TBFavorites.h"

@interface TBStationViewController ()

@property (strong, nonatomic) IBOutlet UIView* parkingContainerView;
@property (strong, nonatomic) IBOutlet UIView* bikeContainerView;

@property (strong, nonatomic) IBOutlet UILabel* availSpaceLabel;
@property (strong, nonatomic) IBOutlet UILabel* availBikeLabel;

@property (strong, nonatomic) IBOutlet UISwitch* favoriteSwitch;

- (IBAction)favoriteValueChanged:(id)sender;

@end

@implementation TBStationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.station = self.station;
}

- (void)setStation:(TBStation *)station {
    _station = station;
    
    self.availSpaceLabel.text = [NSString stringWithFormat:@"%ld", (long)station.availSpace];
    self.availBikeLabel.text = [NSString stringWithFormat:@"%ld", (long)station.availBike];
    
    self.parkingContainerView.layer.cornerRadius = 5.0f;
    self.bikeContainerView.layer.cornerRadius = 5.0f;
    
    self.parkingContainerView.backgroundColor = station.availSpaceColor;
    self.bikeContainerView.backgroundColor = station.availBikeColor;
    
    self.favoriteSwitch.on = [[TBFavorites instance] isFavoriteStationID:station.sid];

    self.title = station.stationName;
    self.navigationItem.title = self.title;
}

- (IBAction)favoriteValueChanged:(id)sender {
    [[TBFavorites instance] setStationID:self.station.sid favorite:self.favoriteSwitch.on];
}

@end