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

@interface TBStationTableViewCell () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel* stationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* subtitleLabel;
@property (strong, nonatomic) IBOutlet TBAvailabilityView* availabilityView;
@property (strong, nonatomic) IBOutlet TBTintedView* availabilityIndicatorView;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) MKDistanceFormatter* distanceFormatter;

@end

@implementation TBStationTableViewCell

- (void)awakeFromNib {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    
    self.distanceFormatter = [[MKDistanceFormatter alloc] init];
    self.distanceFormatter.units = MKDistanceFormatterUnitsMetric;
    self.distanceFormatter.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
}

- (void)setStation:(TBStation *)station {
    _station = station;
    
    self.availabilityView.station = self.station;
    self.stationNameLabel.text = self.station.stationName;
    self.availabilityIndicatorView.fillColor = self.station.indicatorColor;
    
    [self locationManager:self.locationManager didUpdateLocations:nil];
}

- (void)prepareForReuse {
    self.subtitleLabel.hidden = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // hide label if no location services
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        self.subtitleLabel.hidden = YES;
    }
    
    if (self.locationManager.location) {
        CLLocationDistance distance = [self.station distanceFromLocation:self.locationManager.location];
        NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] init];

        if (distance < 10000) {
            [desc appendAttributedString:[[NSAttributedString alloc] initWithString:[self.distanceFormatter stringFromDistance:distance] attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor] }]];
        }
        else {
            [desc appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"far", nil) attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor] }]];
        }
        
        self.subtitleLabel.attributedText = desc;
        self.subtitleLabel.hidden = NO;
    }
    else {
        self.subtitleLabel.hidden = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // hide when no location
    self.subtitleLabel.hidden = YES;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorized) {
        self.subtitleLabel.hidden = YES;
    }
}

@end
