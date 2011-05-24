//
//  StationList+City.Paris.m
//  telobike
//
//  Created by eladb on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"

@implementation StationList (City)

- (NSString*)city
{
    return @"paris";
}

- (CLLocationCoordinate2D)center
{
    return CLLocationCoordinate2DMake(48.8609, 2.350);
}

- (NSString*)listTitle
{
    return @"Paris - Vélib'";
}

- (NSString*)disclaimer
{
    return @"Vélib' is responsible for the data";
}


@end
