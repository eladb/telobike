//
//  TBGoogleMapsRouting.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/11/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBGoogleMapsRouting.h"

@implementation TBGoogleMapsRouting

+ (BOOL)routeFromAddress:(NSString*)startAddress toAddress:(NSString*)destinationAddress {
	NSMutableString *googleMapsURLString = [NSMutableString stringWithFormat:@"%@?", @"comgooglemaps://"];
	NSMutableArray *components = [NSMutableArray array];
		
	if (startAddress && destinationAddress) {
		[components addObject:[[self class] parameterStringWithKey:@"saddr" value:startAddress]];
		[components addObject:[[self class] parameterStringWithKey:@"daddr" value:destinationAddress]];
	}
    
    [components addObject:[[self class] parameterStringWithKey:@"directionsmode" value:@"walking"]];
    
	NSString *componentsString = [components componentsJoinedByString:@"&"];
    if ([componentsString length] > 0) {
        [googleMapsURLString appendFormat:@"&%@", componentsString];
    }
	
	NSURL *googleMapsURL = [NSURL URLWithString:[googleMapsURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (![[UIApplication sharedApplication] canOpenURL:googleMapsURL]) {
        return NO;
    }

    [[UIApplication sharedApplication] openURL:googleMapsURL];
    return YES;
}

+ (NSString *)parameterStringWithKey:(NSString *)key value:(NSString *)value {
	return [NSString stringWithFormat:@"%@=%@", key, value];
}


@end
