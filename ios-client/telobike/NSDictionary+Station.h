//
//  NSDictionary+Station.h
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSDictionary (Station)

- (NSString*)stationName;
- (double)latitude;
- (double)longitude;
- (CLLocation*)location;
- (CLLocationCoordinate2D)coords;
- (BOOL)isActive;
- (NSDate*)lastUpdate;
- (NSString*)lastUpdateDesc;
- (BOOL)isOnline;
- (NSString*)statusText;

- (NSInteger)availBike;
- (NSInteger)availSpace;
- (NSString*)availBikeDesc;
- (NSString*)availSpaceDesc;
- (UIColor*)availSpaceColor;
- (UIColor*)availBikeColor;

- (UIImage*)markerImage;
- (UIImage*)listImage;

- (NSArray*)tags;
- (NSString*)address;

- (NSString*)sid;

- (CLLocationDistance)distanceFromLocation:(CLLocation*)location;
- (BOOL)isMyLocation;

@end
