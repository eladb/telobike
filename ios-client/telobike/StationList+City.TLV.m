//
//  StationList+Cities+TLV.m
//  telobike
//
//  Created by eladb on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"

@implementation StationList (City)

- (NSString*)city
{
    return @"tlv";
}

- (CLLocationCoordinate2D)center
{
    return CLLocationCoordinate2DMake(32.069629, 34.777222);
}

- (NSString*)listTitle
{
    return NSLocalizedString(@"Tel-o-fun Stations", @"Title of the list");
}

- (NSString*)disclaimer
{
    return NSLocalizedString(@"TELOFUN_DISCLAIMER", @"Disclaimer for first time");
}

@end
