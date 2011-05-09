//
//  StationCalloutView.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationCalloutView.h"
#import "NSDictionary+Station.h"

@implementation StationCalloutView

@synthesize stationName=_stationName;
@synthesize image=_image;
@synthesize notActive=_notActive;
@synthesize bikeAvail=_bikeAvail;
@synthesize spacesAvail=_spacesAvail;
@synthesize bikeAvailLabel=_bikeAvailLabel;
@synthesize spacesAvailLabel=_spacesAvailLabel;

- (void)dealloc
{
    [_stationName release];
    [_image release];
    [_notActive release];
    [_bikeAvail release];
    [_spacesAvail release];
    [_bikeAvailLabel release];
    [_spacesAvailLabel release];
    [_station release];
    
    [super dealloc];
}

- (NSDictionary*)station
{
    return _station;
}

- (void)setStation:(NSDictionary *)station
{
    [_station release];
    _station = [station retain];

    _stationName.text = [station stationName];
    _image.image = [station listImage];
    _notActive.hidden = [station isActive];
    
    _spacesAvail.text = [station availSpaceDesc];
    _bikeAvail.text = [station availBikeDesc];
    if ([station availSpaceColor]) _spacesAvail.textColor = [station availSpaceColor];
    if ([station availBikeColor]) _bikeAvail.textColor = [station availBikeColor];
}

@end
