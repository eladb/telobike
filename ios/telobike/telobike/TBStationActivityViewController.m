//
//  TBStationActivityViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/6/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationActivityViewController.h"
#import "TBToggleFavoritesActivity.h"
#import "JNJGoogleMapsActivity.h"

@interface TBStationActivityViewController ()

@end

@implementation TBStationActivityViewController

- (id)initWithStation:(TBStation*)station {
    TBToggleFavoritesActivity* toggleFavorites = [[TBToggleFavoritesActivity alloc] initWithStation:station];
    JNJGoogleMapsActivity* navigate = [[JNJGoogleMapsActivity alloc] init];
    navigate.latitude = @(station.coordinate.latitude);
    navigate.longitude = @(station.coordinate.longitude);
    navigate.directionMode = JNJGoogleMapsDirectionMode.walking;
    NSString* sourceAddress = @"";
    NSString* destAddress = [NSString stringWithFormat:@"%g,%g", station.coordinate.latitude, station.coordinate.longitude];
    NSArray* activityItems = @[ @"Tel-o-Fun station", sourceAddress, destAddress ];
    NSArray* applicationActivities = @[ toggleFavorites, navigate ];
    self = [super initWithActivityItems:activityItems applicationActivities:applicationActivities];
    if (self) {
        self.excludedActivityTypes = @[ UIActivityTypePostToFacebook,
                                        UIActivityTypePostToTwitter,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeMessage,
                                        UIActivityTypeMail,
                                        UIActivityTypePrint,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList,
                                        UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo,
                                        UIActivityTypePostToTencentWeibo,
                                        UIActivityTypeAirDrop ];
    }
    return self;
}

@end
