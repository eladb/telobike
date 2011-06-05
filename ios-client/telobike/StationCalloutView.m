//
//  StationCalloutView.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StationCalloutView.h"
#import "NSDictionary+Station.h"
#import "ReportProblem.h"

@implementation StationCalloutView

@synthesize stationName=_stationName;
@synthesize image=_image;
@synthesize notActive=_notActive;
@synthesize bikeAvail=_bikeAvail;
@synthesize spacesAvail=_spacesAvail;
@synthesize bikeAvailLabel=_bikeAvailLabel;
@synthesize spacesAvailLabel=_spacesAvailLabel;
@synthesize parentController=_parentController;

- (void)dealloc
{
    [_parentController release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSDictionary*)station
{
    return _station;
}

- (void)setStation:(NSDictionary *)station
{
    (void)(self.view); // load from nib.
    
    [_station release];
    _station = [station retain];

    _stationName.text = [station stationName];
    _image.image = [station listImage];
    _notActive.hidden = [station isActive];

    _spacesAvail.text = [NSString stringWithFormat:@"%d", [station availSpace]];
    _bikeAvail.text = [NSString stringWithFormat:@"%d", [station availBike]];

    if ([station availSpaceColor]) _spacesAvail.textColor = [station availSpaceColor];
    if ([station availBikeColor]) _bikeAvail.textColor = [station availBikeColor];
}

- (IBAction)navigate:(id)sender
{
    NSString* dest = [NSString stringWithFormat:@"%@,%@", [_station objectForKey:@"longitude"], [_station objectForKey:@"latitude"]];
    NSString* urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@", dest];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];    
}

- (IBAction)reportProblem:(id)sender
{
    ReportProblem* p = [[[ReportProblem alloc] initWithParent:self.parentController station:self.station] autorelease];
    [p show];
}

@end
