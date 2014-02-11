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

+ (UIImage*)circleWithRadius:(CGFloat)sz fillColor:(UIColor*)fillColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz, sz), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat corderRadius = sz / 2.0;
    CGFloat air = 1.0 + borderWidth;
    CGRect slotRect = CGRectMake(air, air, sz - air * 2, sz - air * 2);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:slotRect cornerRadius:corderRadius];
    if (fillColor) {
        CGContextSetFillColorWithColor(ctx, [fillColor CGColor]);
        [path fill];
    }
    if (borderColor) {
        CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
        [path setLineWidth:borderWidth];
        [path stroke];
    }
    UIImage* marker = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return marker;
}

+ (UIImage*)markerImageForColor:(UIColor*)color {
    return [TBStation circleWithRadius:15.0f fillColor:color borderWidth:0.0f borderColor:nil];
}

+ (UIImage*)selectedMarkerImageForColor:(UIColor*)color {

    return [TBStation circleWithRadius:50.0f
                             fillColor:color
                           borderWidth:10.0f
                           borderColor:[color colorWithAlphaComponent:0.4]];
}

+ (UIImage*)selectedMarkerImageForState:(StationState)state
{
    static NSMutableDictionary* cache = NULL;
    if (!cache) cache = [NSMutableDictionary new];
    
    NSNumber* key = [NSNumber numberWithInt:state];
    UIImage* cachedImage = [cache objectForKey:key];
    if (!cachedImage) {
        UIImage* inner = [TBStation imageWithNameFormat:@"map-%@" state:state];
        UIImage* overlay = [UIImage imageNamed:@"map-selection-mask"];
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
        
        _fullSlotColor = _availBikeColor;
        _emptySlotColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        
        if (_availSpaceColor == yellow) {
            _emptySlotColor = yellow;
        }
    }
    
    // load images for list and markers
    _listImage = [TBStation imageWithNameFormat:@"list-%@.png" state:[self state]];
    _markerImage = [TBStation markerImageForState:[self state]];
//    _markerImage = [TBStation markerImageForColor:self.indicatorColor];
    _selectedMarkerImage = _markerImage;
//    _selectedMarkerImage = [TBStation selectedMarkerImageForColor:self.indicatorColor];
    
    _isMyLocation = [_sid isEqualToString:@"0"];
    if (_isMyLocation)
    {
        _stationName = NSLocalizedString(@"MYLOCATION_TITLE", nil);
//        _availBikeDesc = NSLocalizedString(@"MYLOCATION_DESC", nil);
//        _availSpaceDesc = [NSString string];
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

//- (CLLocationDistance)distanceFromLocation:(CLLocation*)aLocation
//{
//    CLLocation* stationLocation = [[CLLocation new] initWithLatitude:self.latitude longitude:self.longitude];
//    return [aLocation distanceFromLocation:stationLocation];
//}

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

//    // check if the filter text is in the station name
//    if (self.stationName.length > 0 && [self.stationName rangeOfString:keyword options:NSCaseInsensitiveSearch].length) return YES;
//    
//    // check if the filter text is in the address
//    if (self.address.length > 0 && [self.address rangeOfString:keyword options:NSCaseInsensitiveSearch].length) return YES;
//    
//    if (self.tags) {
//        // check if any of the tags match
//        for (NSString* tag in self.tags) {
//            if ([tag rangeOfString:keyword options:NSCaseInsensitiveSearch].length) return YES;
//        }
//    }
    
    return NO;
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