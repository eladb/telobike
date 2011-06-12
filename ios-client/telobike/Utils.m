//
//  Utils.m
//  telobike
//
//  Created by eladb on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"


@implementation Utils

+ (NSString*)currentLanguage
{
    NSString* langSetting = [[NSUserDefaults standardUserDefaults] stringForKey:@"stationsLanguage"];
    if (langSetting && langSetting.length > 0) return langSetting;

    // return the iOS settings
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (NSString*)formattedDistance:(CLLocationDistance)distance
{
    NSString* dist;
    if (distance < 1000) dist = [NSString stringWithFormat:@"%.0f%@", distance, NSLocalizedString(@"DISTANCE_METERS", nil)];
    else dist = [NSString stringWithFormat:@"%.1f%@", (distance/1000.0), NSLocalizedString(@"DISTANCE_KM", nil)];
    return dist;
}

@end

@implementation NSDictionary (Extensions)

- (NSString*)localizedStringForKey:(NSString*)key
{
    NSString* result;
    
    // try 'key.lang' first as the key
    NSString* lang = [Utils currentLanguage];
    result = [self objectForKey:[NSString stringWithFormat:@"%@.%@", key,lang]];
    
    // if we couldn't find this, fall back to the non-localized version
    if (!result) 
    {
        result = [self objectForKey:key];
    }
    
    return result; //[NSString stringWithFormat:@"%@.%@", lang, result];
}

- (CLLocation*)locationForKey:(NSString *)key
{
    NSString* str = [self objectForKey:key];
    if (!str) return nil;
    
    NSArray* components = [str componentsSeparatedByString:@","];
    if (components.count != 2) 
    {
        NSLog(@"invalid geopt format: %@", str);
        return nil;   
    }
    
    NSString* latString = [components objectAtIndex:0];
    NSString* lngString = [components objectAtIndex:1];
    
    if (latString != nil && lngString != nil && latString.length > 0 && lngString.length > 0)
    {
        NSLog(@"bad string format for lat/lon (%@)", str);
        return nil;
    }
    
    CLLocationDegrees lat = [latString doubleValue];
    CLLocationDegrees lng = [lngString doubleValue];
    
    return [[[CLLocation alloc] initWithLatitude:lat longitude:lng] autorelease];
}

- (NSURL*)urlForKey:(NSString*)key
{
    NSString* s = [self objectForKey:key];
    if (!s) return nil;
    return [NSURL URLWithString:s];
}

@end