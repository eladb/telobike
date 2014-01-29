//
//  TBServer.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "TBServer.h"
#import "TBStation.h"

static NSString*  kServerBaseURL            = @"http://telobike.citylifeapps.com";

@interface TBServer () <CLLocationManagerDelegate>

@property (strong, nonatomic) AFHTTPRequestOperationManager* server;
@property (strong, nonatomic) NSURLCache*                    cache;
@property (strong, nonatomic) NSArray*                       stations;
@property (strong, nonatomic) TBCity*                        city;
@property (strong, nonatomic) CLLocationManager*             locationManager;

@end

@implementation TBServer

+ (TBServer *)instance
{
    static TBServer* i = NULL;
    if (!i) {
        i = [[TBServer alloc] init];
    }
    
    return i;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        NSURL* url  = [NSURL URLWithString:kServerBaseURL];
        self.server = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        
        [self parseCityResponse:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"city"]];

        id cachedStationsResponse = [[NSUserDefaults standardUserDefaults] arrayForKey:@"stations"];
        if (!cachedStationsResponse) {
            NSURL* sampleDataURL = [[NSBundle mainBundle] URLForResource:@"sample-data" withExtension:@"json"];
            NSData* sampleData = [NSData dataWithContentsOfURL:sampleDataURL];
            cachedStationsResponse = [NSJSONSerialization JSONObjectWithData:sampleData options:0 error:nil];
        }
        
        [self parseStationsResponse:cachedStationsResponse];
        [self reloadStations:nil];
        [self reloadCity:nil];
    }
    return self;
}

#pragma mark - Stations


- (void)parseStationsResponse:(NSArray*)responseObject {
    if (!responseObject || ![responseObject isKindOfClass:[NSArray class]]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* stationByID = [self.stations dictionaryForStationsByID];
        
        NSMutableArray* stations = [[NSMutableArray alloc] initWithArray:self.stations];
        for (NSDictionary* s in responseObject) {
            TBStation* station = [[TBStation alloc] initWithDictionary:s];
            
            // if we already have a station, just replace it's content and don't replace the object
            TBStation* existingStation = stationByID[station.sid];
            if (existingStation) {
                existingStation.dict = s;
            }
            else {
//                NSLog(@"new station %@", station.sid);
                [stations addObject:station];
            }
        }
        
        self.stations = stations;
    });
}

- (void)reloadStations:(void (^)())completion {
    if (!completion) completion = ^{};
    
    [_server GET:@"/tlv/stations" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseStationsResponse:responseObject];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"stations"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        completion();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error loading stations: %@", error);
        completion();
    }];
}

#pragma mark - City

- (void)parseCityResponse:(NSDictionary*)responseObject {
    if (!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    self.city = [[TBCity alloc] initWithDictionary:responseObject];
}

- (void)reloadCity:(void (^)())completion {
    if (!completion) completion = ^{};
    
    [_server GET:@"/cities/tlv" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseCityResponse:responseObject];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"city"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        completion();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error loading city: %@", error);
        completion();
    }];
}

#pragma mark - Push token

- (void)postPushToken:(NSString*)token completion:(void(^)(void))completion {
    if (!completion) completion = ^{};
    NSString* path = [NSString stringWithFormat:@"/push?token=%@", token];
    [_server POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"push succeeded");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"push failed: %@", error);
    }];
}

#pragma mark - Sort

- (CLLocation *)currentLocation {
    return self.locationManager.location;
}

- (NSArray*)sortStationsByDistance:(NSArray*)stations {
    CLLocation* location = self.locationManager.location;
    
    // no location, sort array from north to south by fixing current location
    // to the north of city center.
    if (!location) {
        location = [[CLLocation alloc] initWithLatitude:0.0f longitude:[TBServer instance].city.cityCenter.coordinate.longitude];
    }
    
    return [stations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TBStation* station1 = obj1;
        TBStation* station2 = obj2;
        CLLocationDistance distance1 = [station1.location distanceFromLocation:location];
        CLLocationDistance distance2 = [station2.location distanceFromLocation:location];
        return distance1 - distance2;
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
}

@end

@implementation NSArray (Stations)

- (NSDictionary*)dictionaryForStationsByID {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    for (TBStation* station in self) {
        dict[station.sid] = station;
    }
    return dict;
}

@end