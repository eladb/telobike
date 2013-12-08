//
//  TBCity.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBCity.h"
#import "Utils.h"

@interface TBCity ()

@property (strong, nonatomic) NSDictionary* dict;

@end

@implementation TBCity

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.dict = dict;
    }
    return self;
}

- (NSString*)cityName { return [[_dict objectForKey:@"city_name.en"] stringByReplacingOccurrencesOfString:@"-" withString:@" "]; }
- (NSString*)mail { return [_dict objectForKey:@"mail"]; }
- (NSString*)serviceName { return [_dict localizedStringForKey:@"service_name"]; }
- (NSString*)mailTags { return [_dict objectForKey:@"mail_tags"]; }
- (NSArray*)messages { return [_dict objectForKey:@"messages"]; }
- (CLLocation*)cityCenter { return [_dict locationForKey:@"city_center"]; }
- (NSString*)disclaimer { return [_dict objectForKey:@"disclaimer"]; }
- (NSURL*)infoURL { return [_dict urlForKey:@"info_url"]; }

- (CLCircularRegion *)region {
    return [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(32.08282450, 34.77996850) radius:9108.0f identifier:self.cityName];
}

@end
