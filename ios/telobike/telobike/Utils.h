//
//  Utils.h
//  telobike
//
//  Created by eladb on 5/9/11.
//  Copyright 2011 Citylifeapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TBCategories : NSObject

+ (NSString*)currentLanguage;
+ (NSString*)formattedDistance:(CLLocationDistance)distance;

@end

@interface NSDictionary (Extensions)

- (NSString*)localizedStringForKey:(NSString*)key;
- (CLLocation*)locationForKey:(NSString*)key;
- (NSURL*)urlForKey:(NSString*)key;
- (NSDate*)jsonDateForKey:(NSString*)key;

@end

@interface NSString (JsonDate)

- (NSDate*)jsonDate;


@end

@interface NSDate (JsonDate)

- (NSString*)jsonString;

@end