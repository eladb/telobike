//
//  Utils.h
//  telobike
//
//  Created by eladb on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Utils : NSObject 

+ (NSString*)currentLanguage;

@end

@interface NSDictionary (Extensions)

- (NSString*)localizedStringForKey:(NSString*)key;
- (CLLocation*)locationForKey:(NSString*)key;
- (NSURL*)urlForKey:(NSString*)key;

@end