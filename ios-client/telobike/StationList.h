//
//  StationList.h
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface StationList : NSObject 
{
    NSArray* _stations;
}

@property (nonatomic, readonly) NSArray* stations;

+ (StationList*)instance;

- (void)refreshStationsWithCompletion:(void(^)())completionBlock;

@end

@interface StationList (City)

- (NSString*)city;
- (CLLocationCoordinate2D)center;
- (NSString*)listTitle;
- (NSString*)disclaimer;

@end

