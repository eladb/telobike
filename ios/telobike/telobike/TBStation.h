//
//  NSDictionary+Station.h
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

@property (nonatomic, readonly) NSString* stationName;
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly) CLLocation* location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, readonly) NSDate* lastUpdate;
@property (nonatomic, readonly) NSTimeInterval freshness;
@property (nonatomic, readonly) NSString* lastUpdateDesc;
@property (nonatomic, readonly) BOOL isOnline;
@property (nonatomic, readonly) NSString* statusText;
@property (nonatomic, readonly) NSInteger availBike;
@property (nonatomic, readonly) NSInteger availSpace;
@property (nonatomic, readonly) NSString* availBikeDesc;
@property (nonatomic, readonly) NSString* availSpaceDesc;
@property (nonatomic, readonly) UIColor* availSpaceColor;
@property (nonatomic, readonly) UIColor* availBikeColor;
@property (nonatomic, assign) BOOL favorite;

@property (nonatomic, readonly) StationState state;
@property (nonatomic, readonly) AmountState parkState;
@property (nonatomic, readonly) AmountState bikeState;

@property (nonatomic, readonly) UIImage* markerImage;
@property (nonatomic, readonly) UIImage* selectedMarkerImage;
@property (nonatomic, readonly) UIImage* listImage;

@property (nonatomic, readonly) NSArray* tags;
@property (nonatomic, readonly) NSString* address;
@property (nonatomic, readonly) NSString* sid;
@property (nonatomic, readonly) BOOL isMyLocation;

@property (nonatomic, assign) double_t distance;

- (id)initWithDictionary:(NSDictionary*)dict;
+ (TBStation*)myLocationStation;

- (CLLocationDistance)distanceFromLocation:(CLLocation*)location;

@end
