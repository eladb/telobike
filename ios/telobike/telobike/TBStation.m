//
//  NSDictionary+Station.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "TBStation.h"
#import "TBFavorites.h"

static const NSTimeInterval kFreshnessTimeInterval = 60 * 30; // 30 minutes
static const NSInteger kMarginalBikeAmount = 3;

@implementation TBStation

+ (UIImage*)imageWithNameFormat:(NSString*)fmt state:(StationState)state
{
    NSString* name = nil;
    
    switch (state) {
        case StationOK:
            name = @"green";
            break;
            
        case StationEmpty:
            name = @"redempty";
            break;
            
        case StationFull:
            name = @"redfull";
            break;
            
        case StationInactive:
            name = @"gray";
            break;
            
        case StationMarginal:
            name = @"yellow";
            break;
            
        case StationMarginalFull:
            name = @"yellowfull";
            break;
            
        case StationUnknown:
        default:
            name = @"black";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:fmt, name]];    
}

+ (UIImage*)markerImageForState:(StationState)state
{
    return [TBStation imageWithNameFormat:@"map-%@.png" state:state];
}

+ (UIImage*)selectedMarkerImageForState:(StationState)state
{
    static NSMutableDictionary* cache = NULL;
    if (!cache) cache = [NSMutableDictionary new];
    
    NSNumber* key = [NSNumber numberWithInt:state];
    UIImage* cachedImage = [cache objectForKey:key];
    if (!cachedImage) {
        UIImage* inner = [TBStation imageWithNameFormat:@"map-%@.png" state:state];
        UIImage* overlay = [UIImage imageNamed:@"map-selection-mask.png"];
        UIGraphicsBeginImageContextWithOptions(overlay.size, NO, 0.0f);
        [overlay drawAtPoint:CGPointMake(0.0f, 0.0f)];
        [inner drawAtPoint:CGPointMake(8.5f, 8.5f) blendMode:kCGBlendModeOverlay alpha:1.0];
        cachedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [cache setObject:cachedImage forKey:key];
    }
    
    return cachedImage;
}

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;

    _sid = [dict objectForKey:@"sid"];
    
    _stationName = [dict localizedStringForKey:@"name"];
    _latitude    = [[dict objectForKey:@"latitude"] doubleValue];
    _longitude   = [[dict objectForKey:@"longitude"] doubleValue];
    _location    = [dict locationForKey:@"location"];
    _lastUpdate  = [dict jsonDateForKey:@"last_update"];
    _tags        = [dict objectForKey:@"tags"];
    _address     = [dict localizedStringForKey:@"address"];
    _availBike   = [[dict objectForKey:@"available_bike"] intValue];
    _availSpace  = [[dict objectForKey:@"available_spaces"] intValue];
    _totalSlots  = _availBike + _availSpace;
    
    // if address and name are the same, remove the address
    if ([_stationName localizedCaseInsensitiveCompare:_address] == NSOrderedSame) {
        _address = nil;
    }
    
    _coordinate = CLLocationCoordinate2DMake([self latitude], [self longitude]);
    _freshness = [_lastUpdate timeIntervalSinceNow];
    _isOnline = _lastUpdate != nil && _freshness < kFreshnessTimeInterval;
    _isActive = !_isOnline || _availBike > 0 || _availSpace > 0;
    
    if (!_lastUpdate) _lastUpdateDesc = NSLocalizedString(@"Offline", nil);
    else _lastUpdateDesc = [NSString stringWithFormat:@"Last updated: %.0fmin ago", _freshness / 60.0];
    
    if (!_isOnline) _statusText = NSLocalizedString(@"Offline", nil);
    else if (!_isActive) _statusText = NSLocalizedString(@"Inactive station", nil);
    
    if (_statusText) _availBikeDesc = _statusText;
    else _availBikeDesc = [NSString stringWithFormat:@"%ld", (long)_availBike, NSLocalizedString(@"Bicycles", @"Number of bicycle")];
    
    if (!_isOnline || !_isActive) _availSpaceDesc = @"";
    else _availSpaceDesc = [NSString stringWithFormat:@"%ld", (long)_availSpace, NSLocalizedString(@"Slots", @"number of slots available")];
    
    UIColor* red    = [UIColor colorWithRed:191.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
    UIColor* yellow = [UIColor colorWithRed:218/255.0 green:171/255.0 blue:0/255.0 alpha:1.0];
    UIColor* green  = [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:0.0f alpha:1.0f];
    
    _indicatorColor = nil;
    
    // set red color for bike and space if either of them is 0.
    if (_isActive) {
        if (_availBike == 0) _availBikeColor = red;
        else if (_availBike <= kMarginalBikeAmount) _availBikeColor = yellow;
        else _availBikeColor = green;
        
        if (_availSpace == 0) _availSpaceColor = red;
        else if (_availSpace <= kMarginalBikeAmount) _availSpaceColor = yellow;
        else _availSpaceColor = green;
        
        _indicatorColor = green;
        if (_availBikeColor != green || _availSpaceColor != green) {
            if (_availBikeColor == red || _availSpaceColor == red) {
                _indicatorColor = red;
            }
            else {
                _indicatorColor = yellow;
            }
        }
    }
    
    // load images for list and markers
    _listImage = [TBStation imageWithNameFormat:@"list-%@.png" state:[self state]];
    _markerImage = [TBStation markerImageForState:[self state]];
    _selectedMarkerImage = [TBStation selectedMarkerImageForState:[self state]];
    
    _isMyLocation = [_sid isEqualToString:@"0"];
    if (_isMyLocation)
    {
        _stationName = NSLocalizedString(@"MYLOCATION_TITLE", nil);
        _availBikeDesc = NSLocalizedString(@"MYLOCATION_DESC", nil);
        _availSpaceDesc = [NSString string];
        _listImage = [UIImage imageNamed:@"list-current-location.png"];
    }
}

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.dict = dict;
    }
    return self;
}


- (StationState)state
{
    StationState state = StationOK;
    if (!_isOnline) state = StationUnknown;
    else if (!_isActive) state = StationInactive;
    else if (_availBike == 0) state = StationEmpty;
    else if (_availSpace == 0) state = StationFull;
    else if (_availBike <= kMarginalBikeAmount) state = StationMarginal;
    else if (_availSpace <= kMarginalBikeAmount) state = StationMarginalFull;
    
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
    return [self amountStateForAmount:_availSpace];
}

- (AmountState) bikeState
{
    return [self amountStateForAmount:_availBike];
}

+ (TBStation*)myLocationStation
{
    return [[TBStation alloc] initWithDictionary:[NSDictionary dictionaryWithObject:@"0" forKey:@"sid"]];
}

- (CLLocationDistance)distanceFromLocation:(CLLocation*)aLocation
{
    CLLocation* stationLocation = [[CLLocation new] initWithLatitude:self.latitude longitude:self.longitude];
    return [aLocation distanceFromLocation:stationLocation];
}

- (BOOL)favorite
{
    return [[TBFavorites instance] isFavoriteStationID:_sid];
}

- (void)setFavorite:(BOOL)isFavorite
{
    [[TBFavorites instance] setStationID:_sid favorite:isFavorite];
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return self.stationName;
}

- (NSString *)subtitle
{
    return nil;
}

- (UIImage*)imageWithNameFormat:(NSString*)fmt
{
    return [TBStation imageWithNameFormat:fmt state:[self state]];
}

@end