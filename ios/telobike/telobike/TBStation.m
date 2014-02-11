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

@property (copy, nonatomic) NSString* stationName;
@property (strong, nonatomic) CLLocation* location;
@property (assign, nonatomic) BOOL isActive;
@property (strong, nonatomic) NSDate* lastUpdate;
@property (assign, nonatomic) NSTimeInterval freshness;
@property (assign, nonatomic) BOOL isOnline;
@property (assign, nonatomic) NSInteger availBike;
@property (assign, nonatomic) NSInteger availSpace;
@property (strong, nonatomic) UIColor* availSpaceColor;
@property (strong, nonatomic) UIColor* availBikeColor;
@property (strong, nonatomic) UIColor* fullSlotColor;
@property (strong, nonatomic) UIColor* emptySlotColor;
@property (assign, nonatomic) CGFloat totalSlots;
@property (strong, nonatomic) UIColor* indicatorColor;
@property (assign, nonatomic) StationState state;
@property (strong, nonatomic) UIImage* markerImage;
@property (strong, nonatomic) UIImage* selectedMarkerImage;
@property (strong, nonatomic) UIImage* listImage;

@property (copy, nonatomic) NSString* address;
@property (copy, nonatomic) NSString* sid;

@end

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

    self.sid = [dict objectForKey:@"sid"];
    
    self.stationName = [dict localizedStringForKey:@"name"];
    self.location    = [dict locationForKey:@"location"];
    self.lastUpdate  = [dict jsonDateForKey:@"last_update"];
    self.address     = [dict localizedStringForKey:@"address"];
    self.availBike   = [[dict objectForKey:@"available_bike"] intValue];
    self.availSpace  = [[dict objectForKey:@"available_spaces"] intValue];
    self.totalSlots  = self.availBike + self.availSpace;
    
    // if address and name are the same, remove the address
    if ([self.stationName localizedCaseInsensitiveCompare:self.address] == NSOrderedSame) {
        self.address = nil;
    }
    
    self.freshness = [self.lastUpdate timeIntervalSinceNow];
    self.isOnline = self.lastUpdate != nil && self.freshness < kFreshnessTimeInterval;
    self.isActive = !self.isOnline || self.availBike > 0 || self.availSpace > 0;
    
    UIColor* red    = [UIColor colorWithRed:191.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
    UIColor* yellow = [UIColor colorWithRed:218/255.0 green:171/255.0 blue:0/255.0 alpha:1.0];
    UIColor* green  = [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:0.0f alpha:1.0f];
    UIColor* gray   = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    self.indicatorColor = nil;
    
    // set red color for bike and space if either of them is 0.
    if (self.isActive) {
        if (self.availBike == 0) self.availBikeColor = red;
        else if (self.availBike <= kMarginalBikeAmount) self.availBikeColor = yellow;
        else self.availBikeColor = green;
        
        if (self.availSpace == 0) self.availSpaceColor = red;
        else if (self.availSpace <= kMarginalBikeAmount) self.availSpaceColor = yellow;
        else self.availSpaceColor = green;
        
        self.indicatorColor = green;
        if (self.availBikeColor != green || self.availSpaceColor != green) {
            if (self.availBikeColor == red || self.availSpaceColor == red) {
                self.indicatorColor = red;
            }
            else {
                self.indicatorColor = yellow;
            }
        }
        
        self.fullSlotColor = self.availBikeColor;
        self.emptySlotColor = gray;
        
        if (self.availSpaceColor == yellow) {
            self.emptySlotColor = yellow;
        }
    }
    
    // load images for list and markers
    self.listImage = [TBStation imageWithNameFormat:@"list-%@.png" state:[self state]];
    self.markerImage = [TBStation markerImageForState:[self state]];
    self.selectedMarkerImage = self.markerImage;
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
    if (!self.isOnline) state = StationUnknown;
    else if (!self.isActive) state = StationInactive;
    else if (self.availBike == 0) state = StationEmpty;
    else if (self.availSpace == 0) state = StationFull;
    else if (self.availBike <= kMarginalBikeAmount) state = StationMarginal;
    else if (self.availSpace <= kMarginalBikeAmount) state = StationMarginalFull;
    
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
    return [self amountStateForAmount:self.availSpace];
}

- (AmountState) bikeState
{
    return [self amountStateForAmount:self.availBike];
}

+ (TBStation*)myLocationStation
{
    return [[TBStation alloc] initWithDictionary:[NSDictionary dictionaryWithObject:@"0" forKey:@"sid"]];
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