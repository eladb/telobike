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

static NSString* const kServiceUrl = @"http://telobike.appspot.com";

@interface StationList (Private)

- (NSString*)deviceId;

@end

@implementation StationList

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
        NSURL* stationsFileUrl = [[NSBundle mainBundle] URLForResource:@"stations" withExtension:@"json"];
        NSLog(@"file url = %@", stationsFileUrl);
        NSString* fileContents = [NSString stringWithContentsOfURL:stationsFileUrl encoding:NSUTF8StringEncoding error:nil];
        _stations = [[fileContents JSONValue] retain];
    }
    return self;
}

- (void)dealloc
{
    [_stations release];
    [super dealloc];
}

-(void)refreshStationsWithCompletion:(void(^)())completionBlock
{
    NSString* urlQuery = [NSString stringWithFormat:@"/stations?alt=json&id=%@", [self deviceId]];
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