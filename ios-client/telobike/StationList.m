//
//  StationList.m
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationList.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"

static NSString* const kServiceUrl = @"http://telobike.citylifeapps.com";

@interface StationList (Private)

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
        NSString* bootstrapName = [NSString stringWithFormat:@"stations-%@", [self city]];
        NSURL* stationsFileUrl = [[NSBundle mainBundle] URLForResource:bootstrapName withExtension:@"json"];
        NSLog(@"file url = %@", stationsFileUrl);
        NSString* fileContents = [NSString stringWithContentsOfURL:stationsFileUrl encoding:NSUTF8StringEncoding error:nil];
        NSArray* bootstrapStations = [[fileContents JSONValue] retain];
        
        // delete the availabity information from the bootstrap data since we do not really know it.
        NSMutableArray* stations = [NSMutableArray arrayWithCapacity:[bootstrapStations count]];
        for (NSDictionary* d in bootstrapStations)
        {
            NSMutableDictionary* d2 = [NSMutableDictionary dictionaryWithDictionary:d];
            [d2 removeObjectForKey:@"available_bike"];
            [d2 removeObjectForKey:@"available_spaces"];
            [d2 removeObjectForKey:@"last_update"];
            [stations addObject:d2];
        }
        
        _stations = [stations retain];
    }
    return self;
}

-(void)refreshStationsWithCompletion:(void(^)())completionBlock
{
    NSString* urlQuery = [NSString stringWithFormat:@"/stations?city=%@&id=%@&alt=json", [self city], [self deviceId]];
    NSURL* url = [NSURL URLWithString:urlQuery relativeToURL:[NSURL URLWithString:kServiceUrl]];
    NSLog(@"GET %@", url);
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    [req setNumberOfTimesToRetryOnTimeout:3];
    
    [req setCompletionBlock:^
    {
        if ([req responseStatusCode] != 200) {
            NSLog(@"Error: %@", [req responseString]);
            return;
        }
        
        NSLog(@"%@", [req responseString]);
        
        [_stations release];
        _stations = [[[req responseString] JSONValue] retain];

        if (completionBlock) completionBlock();
    }];
    
    [req startAsynchronous];
}

- (NSArray*)stations
{
    return _stations;
}

@end

@implementation StationList (Private)

- (NSString*)deviceId
{
    NSString* deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceId"];
    if (!deviceId) 
    {
        int x = arc4random() % 10000000;
        deviceId = [NSString stringWithFormat:@"%d", x];
        NSLog(@"Generated device id: %@", deviceId);
        [[NSUserDefaults standardUserDefaults] setValue:deviceId forKey:@"deviceId"];
    }
    
    return deviceId;
}

@end