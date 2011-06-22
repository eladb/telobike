//
//  NavigateToStation.m
//  telobike
//
//  Created by eladb on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NavigateToStation.h"
#import "AppDelegate.h"

static NSString* const kMapsAppSingleShotDefaultsKey = @"mapsAppWarningShown";

@interface NavigateToStation (Private)

- (void)openMapsApp;

@end

@implementation NavigateToStation

@synthesize station=_station;
@synthesize viewController=_viewController;

- (void)dealloc
{
    [_viewController release];
    [_station release];
    [super dealloc];
}

- (void)show
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kMapsAppSingleShotDefaultsKey])
    {
        [self openMapsApp];
        return;
    }
    
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"OPEN_IN_MAPS", nil)
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"OPEN_IN_MAPS_CANCEL", nil) 
                                               destructiveButtonTitle:nil 
                                                     otherButtonTitles:NSLocalizedString(@"OPEN_IN_MAPS_OK", nil), nil] autorelease];
    
    [self retain];
    
    [actionSheet showFromTabBar:_viewController.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self openMapsApp];
            [self release];
            break;
            
        default:
            break;
    }
}

@end

@implementation NavigateToStation (Private)

- (void)openMapsApp
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMapsAppSingleShotDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString* saddr = [NSString string];
    
    CLLocation* currentLocation = [[AppDelegate app] currentLocation];
    if (currentLocation)
    {
        CLLocationDegrees currLat = currentLocation.coordinate.latitude;
        CLLocationDegrees currLong = currentLocation.coordinate.longitude;
        saddr = [NSString stringWithFormat:@"&saddr=%g,%g(Current+Location)", currLat, currLong];
    }
    
    NSString* daddr = [NSString stringWithFormat:@"&daddr=%g,%g(%@)", 
                       _station.latitude,
                       _station.longitude,
                       _station.stationName];
    
    NSString* urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?dirflg=w%@%@", saddr, daddr];
    NSString* encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:encodedString];
    [[UIApplication sharedApplication] openURL:url];
}
                                            


@end