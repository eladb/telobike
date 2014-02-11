//
//  NSDictionary+Station.h
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 Citylifeapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    StationFull,         // red (no park)
    StationEmpty,        // red (no bike)
    StationOK,           // green
    StationMarginal,     // yellow
    StationMarginalFull, // yellow full
    StationInactive,     // gray
    StationUnknown,      // black
} StationState;

typedef enum {
    Green,
    Yellow,
    Red,
} AmountState;

@interface TBStation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSDictionary* dict; // access raw dict

@property (copy, nonatomic, readonly) NSString* stationName;
@property (assign, nonatomic, readonly) double latitude;
@property (assign, nonatomic, readonly) double longitude;
@property (strong, nonatomic, readonly) CLLocation* location;
@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic, readonly) BOOL isActive;
@property (strong, nonatomic, readonly) NSDate* lastUpdate;
@property (assign, nonatomic, readonly) NSTimeInterval freshness;
@property (assign, nonatomic, readonly) BOOL isOnline;
@property (assign, nonatomic, readonly) NSInteger availBike;
@property (assign, nonatomic, readonly) NSInteger availSpace;
@property (strong, nonatomic, readonly) UIColor* availSpaceColor;
@property (strong, nonatomic, readonly) UIColor* availBikeColor;
@property (strong, nonatomic, readonly) UIColor* fullSlotColor;
@property (strong, nonatomic, readonly) UIColor* emptySlotColor;

@property (assign, nonatomic, readonly) CGFloat totalSlots;

@property (strong, nonatomic, readonly) UIColor* indicatorColor;

@property (assign, nonatomic, readonly) StationState state;
@property (assign, nonatomic, readonly) AmountState parkState;
@property (assign, nonatomic, readonly) AmountState bikeState;

@property (strong, nonatomic, readonly) UIImage* markerImage;
@property (strong, nonatomic, readonly) UIImage* selectedMarkerImage;
@property (strong, nonatomic, readonly) UIImage* listImage;

@property (copy, nonatomic, readonly) NSArray* tags;
@property (copy, nonatomic, readonly) NSString* address;
@property (copy, nonatomic, readonly) NSString* sid;
@property (assign, nonatomic, readonly) BOOL isMyLocation;

@property (assign, nonatomic, readonly) double_t distance;

- (id)initWithDictionary:(NSDictionary*)dict;
+ (TBStation*)myLocationStation;

//- (CLLocationDistance)distanceFromLocation:(CLLocation*)location;

- (BOOL)queryKeyword:(NSString*)keyword;

@end

@interface NSArray (FilterStations)

- (NSArray*)filteredStationsArrayWithQuery:(NSString*)query;

@end