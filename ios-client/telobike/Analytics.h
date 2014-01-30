//
//  Analytics.h
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>

@interface Analytics : NSObject

+ (Analytics*)shared;

#pragma mark - Lifetime

- (void)startTracker;

#pragma mark - Pageviews

- (void)pageViewList;
- (void)pageViewMap;
- (void)pageViewTimer;
- (void)pageViewSettings;
- (void)pageViewInfo;

#pragma mark - Events

- (void)eventAppStart;
- (void)eventStartTimer;
- (void)eventStopTimer;
- (void)eventNavigate;
- (void)eventAddFavorite:(NSString*)stationID;
- (void)eventRemoveFavorite:(NSString*)stationID;
- (void)eventReportProblem:(NSString*)problemType;
- (void)eventListCurrentLocation;

@end
