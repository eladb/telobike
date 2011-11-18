//
//  Analytics.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Analytics.h"

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
    // google analytics
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-27122332-1" dispatchPeriod:kGANDispatchPeriodSec delegate:self];
}

- (void)stopTracker
{
    [[GANTracker sharedTracker] stopTracker];
}

#pragma mark - Pageviews

- (void)pageView:(NSString*)page 
{
    NSError* err;
    if (![[GANTracker sharedTracker] trackPageview:page withError:&err]) {
        NSLog(@"GA pageview error: %@", err);
    }
}

- (void)pageViewList       { [self pageView:@"list"]; }
- (void)pageViewMap        { [self pageView:@"map"]; } 
- (void)pageViewTimer      { [self pageView:@"timer"]; }
- (void)pageViewSettings   { [self pageView:@"settings"]; }
- (void)pageViewInfo       { [self pageView:@"info"]; }

#pragma mark - Events

- (void)event:(NSString*)event action:(NSString*)action label:(NSString*)label
{
    NSError* err;
    if (![[GANTracker sharedTracker] trackEvent:event action:action label:label value:-1 withError:&err]) {
        NSLog(@"GA event error: %@", err);
    }
}

- (void)eventAppStart                              { [self event:@"app" action:@"start" label:nil]; }
- (void)eventStartTimer                            { [self event:@"timer" action:@"start" label:nil]; }
- (void)eventStopTimer                             { [self event:@"timer" action:@"stop" label:nil]; }
- (void)eventNavigate                              { [self event:@"navigate" action:@"navigation" label:nil]; }
- (void)eventAddFavorite:(NSString*)stationID      { [self event:@"favorite" action:@"add" label:stationID]; }
- (void)eventRemoveFavorite:(NSString*)stationID   { [self event:@"favorite" action:@"remove" label:stationID]; }
- (void)eventReportProblem:(NSString*)problemType  { [self event:@"problem" action:problemType label:nil]; }
- (void)eventListCurrentLocation;                  { [self event:@"list" action:@"currentLocation" label:nil]; }

#pragma mark - GA Delegate

#pragma mark - Google Analytics

- (void)hitDispatched:(NSString *)hitString
{
    NSLog(@"GA:hitDispatched -- [string=%@]", hitString);
}

- (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)hitsDispatched
              eventsFailedDispatch:(NSUInteger)hitsFailedDispatch
{
    NSLog(@"GA:trackerDispatchDidComplete -- [success=%d,failures=%d]", hitsDispatched, hitsFailedDispatch);
}

@end
