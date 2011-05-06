//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Station.h"

@implementation NSDictionary (Station)

- (NSString*)stationName
{
    return [self objectForKey:@"name"];
}

- (double)latitude
{
    return [[self objectForKey:@"latitude"] doubleValue];
}

- (double)longitude
{
    return [[self objectForKey:@"longitude"] doubleValue];
}

- (CLLocationCoordinate2D)coords
{
    return CLLocationCoordinate2DMake([self latitude], [self longitude]);
}

- (BOOL)isActive
{
    return [self availBike] > 0 || [self availSpace] > 0;
}

- (NSInteger)availBike
{
    return [[self objectForKey:@"available_bike"] intValue];
}

- (NSInteger)availSpace
{
    return [[self objectForKey:@"available_spaces"] intValue];
}

- (NSString*)availBikeDesc
{
    if ([self availBike] == -1) return @"?";
    else return [NSString stringWithFormat:@"%d", [self availBike]];
}

- (NSString*)availSpaceDesc
{
    if ([self availSpace] == -1) return @"?";
    else return [NSString stringWithFormat:@"%d", [self availSpace]];
}

- (UIImage*)markerImage
{
    UIImage* image = [UIImage imageNamed:@"Green.png"];
    if (![self isActive]) image = [UIImage imageNamed:@"Gray.png"];
    else if ([self availBike] == 0) image = [UIImage imageNamed:@"RedEmpty.png"];
    else if ([self availSpace] == 0) image = [UIImage imageNamed:@"RedFull.png"];
    return image;
}

- (UIImage*)listImage
{
    UIImage* image = [UIImage imageNamed:@"GreenMenu.png"];
    if (![self isActive]) image = [UIImage imageNamed:@"GrayMenu.png"];
    else if ([self availBike] == 0) image = [UIImage imageNamed:@"RedEmptyMenu.png"];
    else if ([self availSpace] == 0) image = [UIImage imageNamed:@"RedFullMenu.png"];
    return image;
}

@end
