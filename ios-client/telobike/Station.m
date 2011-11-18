//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Station.h"
#import "Utils.h"
#import "AppDelegate.h"

static const NSTimeInterval kFreshnessTimeInterval = 60 * 30; // 30 minutes
static const NSInteger kMarginalBikeAmount = 3;

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
        if (isActive && availBike > 0 && availBike <= kMarginalBikeAmount) availBikeColor = [[UIColor colorWithRed:218/255.0 green:171/255.0 blue:0/255.0 alpha:1.0] retain];
        
        // load images for list and markers
        markerImage = [[self imageWithNameFormat:@"%@.png"] retain];
        listImage = [[self imageWithNameFormat:@"%@Menu.png"] retain];

        isMyLocation = [sid isEqualToString:@"0"];
        if (isMyLocation) 
        {
            [stationName release]; stationName = [NSLocalizedString(@"MYLOCATION_TITLE", nil) retain];
            [availBikeDesc release]; availBikeDesc = [NSLocalizedString(@"MYLOCATION_DESC", nil) retain];
            [availSpaceDesc release]; availSpaceDesc = [[NSString string] retain];
            [listImage release]; listImage = [[UIImage imageNamed:@"MyLocationMenu.png"] retain];
        }
    }
    return self;
}

- (StationState)state
{
    StationState state = StationOK;
    if (!isOnline) state = StationUnknown;
    else if (!isActive) state = StationInactive;
    else if (availBike == 0) state = StationEmpty;
    else if (availSpace == 0) state = StationFull;
    else if (availBike <= kMarginalBikeAmount) state = StationMarginal;
    
    return state;
}

- (AmountState)amountStateForAmount:(NSInteger)amount
{
    if (amount == 0) return Red;
    if (amount <= kMarginalBikeAmount) return Yellow;
    return Green;
}

- (AmountState)parkState
{
    return [self amountStateForAmount:availSpace];
}

- (AmountState) bikeState
{
    return [self amountStateForAmount:availBike];
}

+ (Station*)myLocationStation
{
    return [[[Station alloc] initWithDictionary:[NSDictionary dictionaryWithObject:@"0" forKey:@"sid"]] autorelease];
}

- (CLLocationDistance)distanceFromLocation:(CLLocation*)aLocation
{
    CLLocation* stationLocation = [[[CLLocation new] initWithLatitude:self.latitude longitude:self.longitude] autorelease];
    return [aLocation distanceFromLocation:stationLocation];
}

- (BOOL)favorite
{
    return [[[AppDelegate app] favorites] isFavoriteStationID:sid];
}

- (void)setFavorite:(BOOL)isFavorite
{
    [[[AppDelegate app] favorites] setStationID:sid favorite:isFavorite];
}

@end

@implementation Station (Private)

- (UIImage*)imageWithNameFormat:(NSString*)fmt
{
    NSString* name = nil;

    switch ([self state]) {
        case StationOK:
            name = @"Green";
            break;
            
        case StationEmpty:
            name = @"RedEmpty";
            break;

        case StationFull:
            name = @"RedFull";
            break;

        case StationInactive:
            name = @"Gray";
            break;

        case StationMarginal:
            name = @"Yellow";
            break;

        case StationUnknown:
        default:
            name = @"Black";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:fmt, name]];
}

@end