//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 Citylifeapps. All rights reserved.
//

#import "Utils.h"
#import "TBStation.h"

static const NSTimeInterval kFreshnessTimeInterval = 60 * 30; // 30 minutes
static const NSInteger kMarginalBikeAmount = 3;

@interface TBStation ()

// station info
@property (copy, nonatomic) NSString* sid;
@property (copy, nonatomic) NSString* stationName;
@property (copy, nonatomic) NSString* address;
@property (strong, nonatomic) CLLocation* location;
@property (assign, nonatomic) NSInteger availBike;
@property (assign, nonatomic) NSInteger availSpace;

// colors
@property (strong, nonatomic) UIColor* fullSlotColor;
@property (strong, nonatomic) UIColor* emptySlotColor;
@property (strong, nonatomic) UIColor* indicatorColor;

// private
@property (assign, nonatomic) BOOL isActive;
@property (assign, nonatomic) BOOL isOnline;

@end

@implementation TBStation

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.dict = dict;
    }
    return self;
}

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;

    self.sid = [dict objectForKey:@"sid"];
    
    self.stationName = [dict localizedStringForKey:@"name"];
    self.location    = [dict locationForKey:@"location"];
    NSDate* lastUpdate  = [dict jsonDateForKey:@"last_update"];
    self.address     = [dict localizedStringForKey:@"address"];
    self.availBike   = [[dict objectForKey:@"available_bike"] intValue];
    self.availSpace  = [[dict objectForKey:@"available_spaces"] intValue];
    
    // if address and name are the same, remove the address
    if ([self.stationName localizedCaseInsensitiveCompare:self.address] == NSOrderedSame) {
        self.address = nil;
    }
    
    NSTimeInterval freshness = [lastUpdate timeIntervalSinceNow];
    self.isOnline = lastUpdate != nil && freshness < kFreshnessTimeInterval;
    self.isActive = !self.isOnline || self.availBike > 0 || self.availSpace > 0;
    
    UIColor* red    = [UIColor colorWithRed:191.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
    UIColor* yellow = [UIColor colorWithRed:218/255.0 green:171/255.0 blue:0/255.0 alpha:1.0];
    UIColor* green  = [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:0.0f alpha:1.0f];
    UIColor* gray   = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    self.indicatorColor = nil;
    self.fullSlotColor = nil;
    self.emptySlotColor = nil;
    
    // set red color for bike and space if either of them is 0.
    if (self.isActive) {
        UIColor* availBikeColor = nil;
        UIColor* availSpaceColor = nil;

        if (self.availBike == 0) availBikeColor = red;
        else if (self.availBike <= kMarginalBikeAmount) availBikeColor = yellow;
        else availBikeColor = green;
        
        if (self.availSpace == 0) availSpaceColor = red;
        else if (self.availSpace <= kMarginalBikeAmount) availSpaceColor = yellow;
        else availSpaceColor = green;
        
        self.indicatorColor = green;
        if (availBikeColor != green || availSpaceColor != green) {
            if (availBikeColor == red || availSpaceColor == red) self.indicatorColor = red;
            else self.indicatorColor = yellow;
        }
        
        self.fullSlotColor = availBikeColor;
        self.emptySlotColor = availSpaceColor == yellow ? yellow : gray;
    }
}

- (UIImage *)markerImage
{
    switch (self.state) {
        case StationOK: return [UIImage imageNamed:@"map-green.png"];
        case StationEmpty: return [UIImage imageNamed:@"map-redempty.png"];
        case StationFull: return [UIImage imageNamed:@"map-redfull.png"];
        case StationInactive: return [UIImage imageNamed:@"map-gray.png"];
        case StationMarginal: return [UIImage imageNamed:@"map-yellow.png"];
        case StationMarginalFull: return [UIImage imageNamed:@"map-yellowfull.png"];
            
        case StationUnknown:
        default:
            return [UIImage imageNamed:@"map-black.png"];
    }
}

- (StationState)state
{
    StationState state = StationOK;
    if (!self.isOnline) state = StationUnknown;
    else if (!self.isActive) state = StationInactive;
    else if (self.availBike == 0) state = StationEmpty;
    else if (self.availSpace == 0) state = StationFull;
    else if (self.availBike <= kMarginalBikeAmount) state = StationMarginal;
    else if (self.availSpace <= kMarginalBikeAmount) state = StationMarginalFull;
    
    return state;
}

#pragma mark - Query

- (BOOL)queryKeyword:(NSString *)keyword {
    if (keyword.length == 0) {
        return YES;
    }

    // trim any whitespace from the keyword
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for (id value in [self.dict allValues]) {
        if ([value isKindOfClass:[NSString class]]) {
            NSString* valueString = value;
            if ([valueString rangeOfString:keyword options:NSCaseInsensitiveSearch].length) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

- (NSString *)title
{
    return self.stationName;
}

- (NSString *)subtitle
{
    return nil;
}

@end

@implementation NSArray (FilterStations)

- (NSArray*)filteredStationsArrayWithQuery:(NSString*)query {
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if (query.length == 0) {
            return YES;
        }
        
        TBStation* station = evaluatedObject;
        
        // split filter to words and see if this station match all the words.
        NSArray* keywords = [query componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        for (NSString* keyword in keywords) {
            if (![station queryKeyword:keyword]) {
                return NO;
            }
        }
        
        // station contains all keywords, it should be included in the list.
        return YES;
    }];
    
    return [self filteredArrayUsingPredicate:predicate];
}

@end