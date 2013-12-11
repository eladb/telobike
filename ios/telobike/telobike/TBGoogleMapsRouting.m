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
	
//	if (self.queryString) {
//		[components addObject:[self parameterStringWithKey:kJNJGoogleMapsQueryKeyQuery value:self.queryString]];
//	}
	
	if (startAddress && destinationAddress) {
		[components addObject:[[self class] parameterStringWithKey:@"saddr" value:startAddress]];
		[components addObject:[[self class] parameterStringWithKey:@"daddr" value:destinationAddress]];
	}
    
//	if (self.latitude && self.longitude) {
//		NSString *position = [NSString stringWithFormat:@"%@,%@", [self.latitude stringValue], [self.longitude stringValue]];
//		[components addObject:[self parameterStringWithKey:kJNJGoogleMapsQueryKeyCenter value:position]];
//	}
    
//	if (self.zoomLevel > 0) {
//		NSString *zoomLevel = [NSString stringWithFormat:@"%i", self.zoomLevel];
//		[components addObject:[self parameterStringWithKey:kJNJGoogleMapsQueryKeyZoom value:zoomLevel]];
//	}
	
//	if (self.mapMode) {
//		[components addObject:[self parameterStringWithKey:kJNJGoogleMapsQueryKeyMapMode value:self.mapMode]];
//	}
	
//	if (self.directionMode) {
//		[components addObject:[self parameterStringWithKey:kJNJGoogleMapsQueryKeyDirectionMode value:self.directionMode]];
//	}
	
//	if ([self.viewTypes count] > 0) {
//		NSString *viewTypes = [self.viewTypes componentsJoinedByString:@","];
//		[components addObject:[self parameterStringWithKey:kJNJGoogleMapsQueryKeyViews value:viewTypes]];
//	}
	
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
