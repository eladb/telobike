//
//  StationList.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"
#import "SBJson.h"
#import "Globals.h"
#import "ASIHTTPRequest+Telobike.h"
#import "NSDictionary+Station.h"

@interface StationList (Private)

- (NSString*)city;
- (NSString*)deviceId;

@end

@implementation StationList

- (void)dealloc
{
    [_stations release];
    [super dealloc];
}

+(StationList*)instance
{
    static StationList* instance = nil;
    if (!instance)
    {
        instance = [StationList new];
    }
    
    return instance;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _stations = nil;
    }
    return self;
}

+ (NSDictionary*)myLocationStation
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    [result setValue:@"0" forKey:@"sid"];
    return result;
}

-(void)refreshStationsWithCompletion:(void(^)())completionBlock
{
    ASIHTTPRequest* req = [ASIHTTPRequest telobikeRequestWithQuery:[NSString stringWithFormat:@"/stations?city=%@",[Globals city]]];

    [req setCompletionBlock:^
    {
        if ([req responseStatusCode] != 200) {
            NSLog(@"Error: %@", [req responseString]);
            return;
        }
        
        NSLog(@"%@", [req responseString]);
        
        NSArray* newStations = [[req responseString] JSONValue];
        NSMutableArray* filteredStations = [NSMutableArray array];
        
        NSDictionary* myLocStation = [StationList myLocationStation];
        [filteredStations addObject:myLocStation];
        
        BOOL showInactiveStations = YES;
        id showInactiveValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"showInactiveStations"];
        if (showInactiveValue)
        {
            showInactiveStations = [showInactiveValue boolValue];
        }

        for (NSDictionary* s in newStations)
        {
            if (![s isActive] && !showInactiveStations && !s.isMyLocation) continue; // filter inactive stations (if setting is enabled)
            [filteredStations addObject:s];
        }
        
        [_stations release];
        _stations = [filteredStations retain];

        if (completionBlock) completionBlock();
    }];
    
    [req setFailedBlock:^
     {
         NSLog(@"Request failed: %@", [req error]);
     }];
    
    [req startAsynchronous];
}

- (NSArray*)stations
{
    return _stations;
}

@end
