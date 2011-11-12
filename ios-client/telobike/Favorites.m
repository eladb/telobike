//
//  Favorites.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Favorites.h"

@implementation Favorites

- (NSString*)defaultsKeyForStationID:(NSString*)stationID
{
    return [NSString stringWithFormat:@"favorite.%@", stationID];
}

- (BOOL)isFavoriteStationID:(NSString*)stationID
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self defaultsKeyForStationID:stationID]];
}

- (void)setStationID:(NSString*)stationID favorite:(BOOL)isFavorite
{
    [[NSUserDefaults standardUserDefaults] setBool:isFavorite forKey:[self defaultsKeyForStationID:stationID]];
}

@end
