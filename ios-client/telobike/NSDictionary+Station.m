//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Station.h"
#import "Utils.h"

@interface NSDictionary (StationPrivate)

- (NSString*)localizedStringForKey:(NSString*)key;

@end

@implementation NSDictionary (Station)

- (NSString*)stationName
{
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

- (CLLocationCoordinate2D)coords
{
    return CLLocationCoordinate2DMake([self latitude], [self longitude]);
}

- (BOOL)isOnline
{
    return [self objectForKey:@"last_update"] != nil;
}

- (BOOL)isActive
{
    return ![self isOnline] || 
           [self availBike] > 0 || [self availSpace] > 0;
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
    if (![self isOnline]) return NSLocalizedString(@"Offline", @"indicates that the station is offline");
    if (![self isActive]) return NSLocalizedString(@"Inactive station", @"indicates that the station is inactive");
    else return [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Bicycle", @"Number of bicycle"), [self availBike]];
}

- (NSString*)availSpaceDesc
{
    if (![self isOnline]) return @"";
    if (![self isActive]) return @"";
    else return [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Slots", @"number of slots available"), [self availSpace]];
}

- (UIImage*)markerImage
{
    UIImage* image = [UIImage imageNamed:@"Green.png"];
    if (![self isOnline]) image = [UIImage imageNamed:@"cycling.png"];
    else if (![self isActive]) image = [UIImage imageNamed:@"Gray.png"];
    else if ([self availBike] == 0) image = [UIImage imageNamed:@"RedEmpty.png"];
    else if ([self availSpace] == 0) image = [UIImage imageNamed:@"RedFull.png"];
    return image;
}

- (UIImage*)listImage
{
    UIImage* image = [UIImage imageNamed:@"GreenMenu.png"];
    if (![self isOnline]) image = [UIImage imageNamed:@"cycling.png"];
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

@end

@implementation NSDictionary (StationPrivate)

- (NSString*)localizedStringForKey:(NSString*)key
{
    NSString* result;

    // try 'key.lang' first as the key
    NSString* lang = [Utils currentLanguage];
    result = [self objectForKey:[NSString stringWithFormat:@"%@.%@", key,lang]];
    
    // if we couldn't find this, fall back to the non-localized version
    if (!result) {
        result = [self objectForKey:key];
    }
        
    return result;
}

@end