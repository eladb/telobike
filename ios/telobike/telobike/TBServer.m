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

@interface TBServer ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* server;
@property (strong, nonatomic) NSURLCache*                    cache;
@property (strong, nonatomic) NSArray*                       stations;
@property (strong, nonatomic) TBCity*                        city;

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
            NSLog(@"new station %@", station.sid);
            [stations addObject:station];
        }
    }
    
    self.stations = stations;
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