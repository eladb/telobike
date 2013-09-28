//
//  TBCity.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TBCity : NSObject


@property (strong, readonly) NSString*   cityName;
@property (strong, readonly) NSString*   mail;
@property (strong, readonly) NSString*   serviceName;
@property (strong, readonly) NSString*   mailTags;
@property (strong, readonly) CLLocation* cityCenter;
@property (strong, readonly) NSString*   disclaimer;
@property (strong, readonly) NSURL*      infoURL;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end
