//
//  Globals.m
//  telobike
//
//  Created by eladb on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Globals.h"


@implementation Globals

+ (NSString*)city
{
    return @"tlv";
}

+ (NSURL*)backendURL
{
    return [NSURL URLWithString:@"http://telobike.citylifeapps.com"];
}

@end
