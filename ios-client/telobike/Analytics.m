//
//  Analytics.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Analytics.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

static const NSInteger kGANDispatchPeriodSec = 10;

@implementation Analytics

+ (Analytics*)shared
{
    static Analytics* instance = NULL;
    if (!instance) instance = [[Analytics alloc] init];
    return  instance;
}

#pragma mark - Lifetime

- (void)startTracker
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] logger].logLevel = kGAILogLevelVerbose;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-27122332-1"];
}

- (void)stopTracker
{
//    [[GANTracker sharedTracker] stopTracker];
}

#pragma mark - Pageviews

- (id<GAITracker>)tracker
{
    return [[GAI sharedInstance] defaultTracker];
}

- (void)pageView:(NSString*)page
{
    NSDictionary* d = [[GAIDictionaryBuilder createEventWithCategory:@"pageview"
                                                             action:@"pageview"
                                                               label:page
                                                               value:nil] build];
    [[self tracker] send:d];
}

- (void)pageViewList       { [self pageView:@"list"]; }
- (void)pageViewMap        { [self pageView:@"map"]; } 
- (void)pageViewTimer      { [self pageView:@"timer"]; }
- (void)pageViewSettings   { [self pageView:@"settings"]; }
- (void)pageViewInfo       { [self pageView:@"info"]; }

#pragma mark - Events

- (void)event:(NSString*)event action:(NSString*)action label:(NSString*)label
{
    NSDictionary* d = [[GAIDictionaryBuilder createEventWithCategory:event
                                                              action:action
                                                               label:label
                                                               value:nil] build];
    [[self tracker] send:d];
}

- (void)eventAppStart                              { [self event:@"app" action:@"start" label:nil]; }
- (void)eventStartTimer                            { [self event:@"timer" action:@"start" label:nil]; }
- (void)eventStopTimer                             { [self event:@"timer" action:@"stop" label:nil]; }
- (void)eventNavigate                              { [self event:@"navigate" action:@"navigation" label:nil]; }
- (void)eventAddFavorite:(NSString*)stationID      { [self event:@"favorite" action:@"add" label:stationID]; }
- (void)eventRemoveFavorite:(NSString*)stationID   { [self event:@"favorite" action:@"remove" label:stationID]; }
- (void)eventReportProblem:(NSString*)problemType  { [self event:@"problem" action:problemType label:nil]; }
- (void)eventListCurrentLocation;                  { [self event:@"list" action:@"currentLocation" label:nil]; }

@end