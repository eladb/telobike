//
//  City.h
//  telobike
//
//  Created by eladb on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface City : NSObject
{
    NSDictionary* _data;
}

+ (City*)instance;

@property (nonatomic, readonly) NSString* cityName;
@property (nonatomic, readonly) NSString* mail;
@property (nonatomic, readonly) NSString* serviceName;
@property (nonatomic, readonly) NSString* mailTags;
@property (nonatomic, readonly) CLLocation* cityCenter;
@property (nonatomic, readonly) NSString* disclaimer;
@property (nonatomic, readonly) NSURL* infoURL;
@property (nonatomic, readonly) NSString* phoneNumber;

- (void)refreshWithCompletion:(void(^)(void))block failure:(void(^)(void))failureBlock useCache:(BOOL)useCache;;

@end
