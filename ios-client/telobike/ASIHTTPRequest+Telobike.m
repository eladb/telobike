//
//  RequestFactory.m
//  telobike
//
//  Created by eladb on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest+Telobike.h"
#import "ASIDownloadCache.h"
#import "Globals.h"

@implementation ASIHTTPRequest (Telobike)

NSString* deviceId()
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

+ (ASIHTTPRequest*)telobikeRequestWithQuery:(NSString*)query
{
    NSString* concatChar = [query rangeOfString:@"?"].length == 1 ? @"&" : @"?";
    NSString* urlQuery = [NSString stringWithFormat:@"%@%@id=%@&alt=json", query, concatChar, deviceId()];
    NSURL* url = [NSURL URLWithString:urlQuery relativeToURL:[Globals backendURL]];
    NSLog(@"GET %@", url);
    
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:url];
    [req setNumberOfTimesToRetryOnTimeout:3];
    [req setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedCachePolicy];
    [req setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [req setDownloadCache:[ASIDownloadCache sharedCache]];
    
    return req;
}

@end
