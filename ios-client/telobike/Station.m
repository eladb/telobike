//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Station.h"
#import "Utils.h"

static const NSTimeInterval kFreshnessTimeInterval = 60 * 30; // 30 minutes

@interface Station (Private)

- (UIImage*)imageWithNameFormat:(NSString*)fmt;

@end

@implementation Station

@synthesize stationName;
@synthesize latitude;
@synthesize longitude;
@synthesize location;
@synthesize coords;
@synthesize isActive;
@synthesize lastUpdate;
@synthesize freshness;
@synthesize lastUpdateDesc;
@synthesize isOnline;
@synthesize statusText;
@synthesize availBike;
@synthesize availSpace;
@synthesize availBikeDesc;
@synthesize availSpaceDesc;
@synthesize availSpaceColor;
@synthesize availBikeColor;
@synthesize markerImage;
@synthesize listImage;
@synthesize tags;
@synthesize address;
@synthesize sid;
@synthesize isMyLocation;
@synthesize distance;

- (void)dealloc
{
    [stationName release];
    [location release];
    [lastUpdate release];
    [lastUpdateDesc release];
    [statusText release];
    [availBikeDesc release];
    [availSpaceDesc release];
    [availSpaceColor release];
    [availBikeColor release];
    [markerImage release];
    [listImage release];
    [tags release];
    [address release];
    [sid release];
    [super dealloc];
}

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        sid = [[dict objectForKey:@"sid"] retain];

        
        stationName = [[dict localizedStringForKey:@"name"] retain];
        latitude    = [[dict objectForKey:@"latitude"] doubleValue];
        longitude   = [[dict objectForKey:@"longitude"] doubleValue];
        location    = [[dict locationForKey:@"location"] retain];
        lastUpdate  = [[dict jsonDateForKey:@"last_update"] retain];
        tags        = [[dict objectForKey:@"tags"] retain];
        address     = [[dict localizedStringForKey:@"address"] retain];
        availBike   = [[dict objectForKey:@"available_bike"] intValue];
        availSpace  = [[dict objectForKey:@"available_spaces"] intValue];

        coords = CLLocationCoordinate2DMake([self latitude], [self longitude]);
        freshness = [lastUpdate timeIntervalSinceNow];
        isOnline = lastUpdate != nil && freshness < kFreshnessTimeInterval;
        isActive = !isOnline || availBike > 0 || availSpace > 0;
        
        if (!lastUpdate) lastUpdateDesc = [NSLocalizedString(@"Offline", nil) retain];
        else lastUpdateDesc = [[NSString stringWithFormat:@"Last updated: %.0fmin ago", freshness / 60.0] retain];
        
        if (!isOnline) statusText = [NSLocalizedString(@"Offline", nil) retain];
        else if (!isActive) statusText = [NSLocalizedString(@"Inactive station", nil) retain];
        
        if (statusText) availBikeDesc = [statusText retain];
        else availBikeDesc = [[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Bicycle", @"Number of bicycle"), availBike] retain];
        
        if (!isOnline || !isActive) availSpaceDesc = [@"" retain];
        else availSpaceDesc = [[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Slots", @"number of slots available"), availSpace] retain];

        // set red color for bike and space if either of them is 0.
        if (isActive && availSpace == 0) availSpaceColor = [[UIColor redColor] retain];
        if (isActive && availBike == 0) availBikeColor = [[UIColor redColor] retain];
        
        // load images for list and markers
        markerImage = [[self imageWithNameFormat:@"%@.png"] retain];
        listImage = [[self imageWithNameFormat:@"%@Menu.png"] retain];

        isMyLocation = [sid isEqualToString:@"0"];
        if (isMyLocation) 
        {
            [stationName release]; stationName = [NSLocalizedString(@"MYLOCATION_TITLE", nil) retain];
            [availBikeDesc release]; availBikeDesc = [NSLocalizedString(@"MYLOCATION_DESC", nil) retain];
            [availSpaceDesc release]; availSpaceDesc = [[NSString string] retain];
            [listImage release]; listImage = [[UIImage imageNamed:@"MyLocation.png"] retain];
        }
    }
    return self;
}

+ (Station*)myLocationStation
{
    return [[[Station alloc] initWithDictionary:[NSDictionary dictionaryWithObject:@"0" forKey:@"sid"]] autorelease];
}

- (CLLocationDistance)distanceFromLocation:(CLLocation*)aLocation
{
    CLLocation* stationLocation = [[CLLocation new] initWithLatitude:self.latitude longitude:self.longitude];
    return [aLocation distanceFromLocation:stationLocation];
}

@end

@implementation Station (Private)

- (UIImage*)imageWithNameFormat:(NSString*)fmt
{
    NSString* name = @"Green";
    if (!isOnline) name = @"Black";
    else if (!isActive) name = @"Gray";
    else if (availBike == 0) name = @"RedEmpty";
    else if (availSpace == 0) name = @"RedFull";
    return [UIImage imageNamed:[NSString stringWithFormat:fmt,name]];
}

@end