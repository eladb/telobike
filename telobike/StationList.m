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
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://telobike.appspot.com/stations?alt=json"]];
    
    [req setCompletionBlock:^
    {
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
