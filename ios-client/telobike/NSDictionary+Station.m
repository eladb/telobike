//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Station.h"
#import "Utils.h"

static const NSTimeInterval kFreshnessTimeInterval = 60 * 30; // 30 minutes

@interface NSDictionary (StationPrivate)

- (NSString*)localizedStringForKey:(NSString*)key;

@end

@implementation NSDictionary (Station)

- (NSString*)stationName
{
    if ([self isMyLocation]) return NSLocalizedString(@"MYLOCATION_TITLE", nil);
    return [self localizedStringForKey:@"name"];
}

- (double)latitude
{
    return [[self objectForKey:@"latitude"] doubleValue];
}

- (double)longitude
{
    return [[self objectForKey:@"longitude"] doubleValue];
}

- (CLLocation*)location
{
    return [self locationForKey:@"location"];
}

- (CLLocationCoordinate2D)coords
{
    return CLLocationCoordinate2DMake([self latitude], [self longitude]);
}

- (NSDate*)lastUpdate
{
    return [self jsonDateForKey:@"last_update"];
}

- (NSTimeInterval)freshness
{
    return -[[self lastUpdate] timeIntervalSinceNow];
}

- (BOOL)isOnline
{
    return [self lastUpdate] != nil && [self freshness] < kFreshnessTimeInterval;
}

- (BOOL)isActive
{
    return ![self isOnline] || [self availBike] > 0 || [self availSpace] > 0;
}

- (NSInteger)availBike
{
    return [[self objectForKey:@"available_bike"] intValue];
}

- (NSInteger)availSpace
{
    return [[self objectForKey:@"available_spaces"] intValue];
}

- (NSString*)lastUpdateDesc
{
    if (![self lastUpdate]) return NSLocalizedString(@"Offline", nil);
    return [NSString stringWithFormat:@"Last updated: %.0fmin ago", [self freshness] / 60.0];
}

- (NSString*)statusText
{
    if (!self.isOnline) return NSLocalizedString(@"Offline", nil);
    if (!self.isActive) return NSLocalizedString(@"Inactive station", nil);
    return nil;
}

- (NSString*)availBikeDesc
{
    if ([self isMyLocation]) return NSLocalizedString(@"MYLOCATION_DESC", nil);
    
    NSString* status = [self statusText];
    if (status) return status;
    
    else return [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Bicycle", @"Number of bicycle"), [self availBike]];
}

- (NSString*)availSpaceDesc
{
    if ([self isMyLocation]) return @"";
    if (![self isOnline]) return @"";
    if (![self isActive]) return @"";
    else return [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Slots", @"number of slots available"), [self availSpace]];
}

- (UIImage*)markerImage
{
    UIImage* image = [UIImage imageNamed:@"Green.png"];
    if (![self isOnline]) image = [UIImage imageNamed:@"Black.png"];
    else if (![self isActive]) image = [UIImage imageNamed:@"Gray.png"];
    else if ([self availBike] == 0) image = [UIImage imageNamed:@"RedEmpty.png"];
    else if ([self availSpace] == 0) image = [UIImage imageNamed:@"RedFull.png"];
    return image;
}

- (UIImage*)listImage
{
    if (self.isMyLocation)
    {
        return [UIImage imageNamed:@"MyLocation.png"];
    }
    
    UIImage* image = [UIImage imageNamed:@"GreenMenu.png"];
    if (![self isOnline]) image = [UIImage imageNamed:@"BlackMenu.png"];
    else if (![self isActive]) image = [UIImage imageNamed:@"GrayMenu.png"];
    else if ([self availBike] == 0) image = [UIImage imageNamed:@"RedEmptyMenu.png"];
    else if ([self availSpace] == 0) image = [UIImage imageNamed:@"RedFullMenu.png"];
    return image;
}

- (UIColor*)availSpaceColor
{
    if (![self isOnline]) return nil;
    if (![self isActive]) return nil;
    if ([self availSpace] == 0) return [UIColor redColor];
    return nil;
}

- (UIColor*)availBikeColor
{
    if (![self isOnline]) return nil;
    if (![self isActive]) return nil;
    if ([self availBike] == 0) return [UIColor redColor];
    return nil;
}

- (NSArray*)tags
{
    return [self objectForKey:@"tags"];    
}

- (NSString*)address
{
    return [self localizedStringForKey:@"address"];
}

- (NSString*)sid
{
    return [self objectForKey:@"sid"];
}

- (CLLocationDistance)distanceFromLocation:(CLLocation*)location
{
    CLLocation* stationLocation = [[CLLocation new] initWithLatitude:[self latitude] longitude:[self longitude]];
    return [location distanceFromLocation:stationLocation];
}

- (BOOL)isMyLocation
{
    return [[self sid] isEqualToString:@"0"];
}

@end