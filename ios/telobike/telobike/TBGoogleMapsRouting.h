//
//  TBGoogleMapsRouting.h
//  telobike
//
//  Created by Elad Ben-Israel on 12/11/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBGoogleMapsRouting : NSObject

+ (BOOL)routeFromAddress:(NSString*)startAddress toAddress:(NSString*)destinationAddress;

@end
