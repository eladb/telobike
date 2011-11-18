//
//  Favorites.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Favorites.h"
#import "Analytics.h"

@implementation Favorites

- (NSString*)defaultsKeyForStationID:(NSString*)stationID
{
    return [NSString stringWithFormat:@"favorite.%@", stationID];
}

- (BOOL)isFavoriteStationID:(NSString*)stationID
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self defaultsKeyForStationID:stationID]];
}

- (void)setStationID:(NSString*)stationID favorite:(BOOL)isFavorite
{
    if (isFavorite) {
        [[Analytics shared] eventAddFavorite:stationID];
    }
    else {
        [[Analytics shared] eventRemoveFavorite:stationID];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isFavorite forKey:[self defaultsKeyForStationID:stationID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
