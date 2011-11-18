//
//  City.m
//  telobike
//
//  Created by eladb on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Globals.h"
#import "Utils.h"
#import "ASIHTTPRequest+Telobike.h"
#import "SBJson.h"
#import "City.h"

@implementation City

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

+ (City*)instance
{
    static City* instance = nil;
    if (!instance)
    {
        instance = [City new];
    }
    
    [instance refreshWithCompletion:nil failure:nil useCache:YES];
    
    return instance;
}

- (NSString*)cityName { return [_data localizedStringForKey:@"city_name"]; }
- (NSString*)mail { return [_data objectForKey:@"mail"]; }
- (NSString*)serviceName { return [_data localizedStringForKey:@"service_name"]; }
- (NSString*)mailTags { return [_data objectForKey:@"mail_tags"]; }
- (NSArray*)messages { return [_data objectForKey:@"messages"]; }
- (CLLocation*)cityCenter { return [_data locationForKey:@"city_center"]; }
- (NSString*)disclaimer { return [_data objectForKey:@"disclaimer"]; }
- (NSURL*)infoURL { return [_data urlForKey:@"info_url"]; }
- (NSString*)phoneNumber { return @"+972544604762"; /*[_data objectForKey:@"phone"];*/ }

- (void)refreshWithCompletion:(void(^)(void))block failure:(void(^)(void))failureBlock useCache:(BOOL)useCache
{
    ASIHTTPRequest* req = [ASIHTTPRequest telobikeRequestWithQuery:[NSString stringWithFormat:@"/cities/%@", [Globals city]] useCache:useCache];
    
    [req setCompletionBlock:^
     {
         if ([req responseStatusCode] != 200) {
             NSLog(@"Error: %@", [req responseString]);
             return;
         }
         
         NSLog(@"%@", [req responseString]);
         
         [_data release];
         _data = [[[req responseString] JSONValue] retain];
         
         if (block) block();
     }];
    
    [req setFailedBlock:^
     {
         NSLog(@"Request failed: %@", [req error]);
         if (failureBlock) failureBlock();
     }];
    
    [req startAsynchronous];
}

@end