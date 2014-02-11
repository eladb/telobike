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

@interface TBStation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSDictionary* dict; // access raw dict

// station info
@property (copy, nonatomic, readonly) NSString* sid;
@property (copy, nonatomic, readonly) NSString* address;
@property (copy, nonatomic, readonly) NSString* stationName;
@property (strong, nonatomic, readonly) CLLocation* location;
@property (assign, nonatomic, readonly) NSInteger availBike;
@property (assign, nonatomic, readonly) NSInteger availSpace;

// colors
@property (strong, nonatomic, readonly) UIColor* fullSlotColor;
@property (strong, nonatomic, readonly) UIColor* emptySlotColor;
@property (strong, nonatomic, readonly) UIColor* indicatorColor;

// state (calculated)
@property (assign, nonatomic, readonly) StationState state;
@property (strong, nonatomic, readonly) UIImage* markerImage;

- (id)initWithDictionary:(NSDictionary*)dict;
- (BOOL)queryKeyword:(NSString*)keyword;

@end

@interface NSArray (FilterStations)

- (NSArray*)filteredStationsArrayWithQuery:(NSString*)query;

@end