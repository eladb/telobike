//
//  TBServer.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBCity.h"

@interface TBServer : NSObject

+ (TBServer*)instance;

@property (strong, readonly) NSArray* stations;
@property (strong, readonly) TBCity* city;

- (void)reloadStations:(void(^)())completion;
- (void)reloadCity:(void(^)())completion;
- (void)postPushToken:(NSString*)token completion:(void(^)(void))completion;

@end
