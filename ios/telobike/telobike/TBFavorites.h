//
//  Favorites.h
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBStation.h"

@interface TBFavorites : NSObject

+ (TBFavorites*)instance;

- (BOOL)isFavoriteStationID:(NSString*)stationID;
- (void)setStationID:(NSString*)stationID favorite:(BOOL)isFavorite;

@end

@interface TBStation (Favorite)

@property (assign, nonatomic, getter=isFavorite) BOOL favorite;

//- (BOOL)isFavorite;
//- (void)setFavorite:(BOOL)favorite;

@end
