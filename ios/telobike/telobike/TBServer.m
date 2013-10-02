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
static NSUInteger kCacheMemoryCapacityBytes = 4 * 1024 * 1024;
static NSUInteger kCacheDiskCapacityBytes   = 4 * 1024 * 1024;

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
    
    NSMutableArray* stations = [[NSMutableArray alloc] init];
    for (NSDictionary* s in responseObject) {
        TBStation* station = [[TBStation alloc] initWithDictionary:s];
        [stations addObject:station];
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

@end
