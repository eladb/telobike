//
//  StationList.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"
#import "JSON.h"
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
        BOOL showInactiveStations = [[NSUserDefaults standardUserDefaults] boolForKey:@"showInactiveStations"];
        for (NSDictionary* s in newStations)
        {
            if (![s isActive] && !showInactiveStations) continue; // filter inactive stations (if setting is enabled)
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
