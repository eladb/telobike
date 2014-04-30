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
} TBStationState;

@interface TBStation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSDictionary* dict; // access raw dict

// station info
@property (readonly, nonatomic) NSString* sid;
@property (readonly, nonatomic) NSString* address;
@property (readonly, nonatomic) NSString* stationName;
@property (readonly, nonatomic) CLLocation* location;
@property (readonly, nonatomic) NSInteger availBike;
@property (readonly, nonatomic) NSInteger availSpace;

// colors
@property (readonly, nonatomic) UIColor* fullSlotColor;
@property (readonly, nonatomic) UIColor* emptySlotColor;
@property (readonly, nonatomic) UIColor* indicatorColor;

// state (color)
@property (readonly, nonatomic) NSDate *lastUpdateTime;
@property (readonly, nonatomic) TBStationState state;
@property (readonly, nonatomic) UIImage* markerImage;

- (id)initWithDictionary:(NSDictionary*)dict;
- (BOOL)queryKeyword:(NSString*)keyword;

@end

@interface NSArray (FilterStations)

- (NSArray*)filteredStationsArrayWithQuery:(NSString*)query;

@end