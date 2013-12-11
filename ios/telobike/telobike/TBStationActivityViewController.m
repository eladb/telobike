//
//  TBStationActivityViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/6/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationActivityViewController.h"

@interface TBStationActivityViewController ()

@end

@implementation TBStationActivityViewController

- (id)initWithStation:(TBStation*)station {
    // create share string
    NSMutableString* shareString = [[NSMutableString alloc] init];
    [shareString appendFormat:NSLocalizedString(@"Tel-o-Fun Station: %@", nil), station.stationName];
    
    if (station.address) {
        [shareString appendString:@"\n"];
        [shareString appendFormat:@"Address: %@", station.address];
    }
    
    [shareString appendString:@"\n"];
    NSString* googleMapsLink = [NSString stringWithFormat:@"http://maps.google.com?q=%g,%g", station.coordinate.latitude, station.coordinate.longitude];
    [shareString appendString:googleMapsLink];
    
    NSArray* activityItems = @[ shareString ];
    NSArray* applicationActivities = @[ ];
    self = [super initWithActivityItems:activityItems applicationActivities:applicationActivities];
    if (self) {
        self.excludedActivityTypes = @[ UIActivityTypePostToFacebook,
                                        UIActivityTypePostToTwitter,
                                        UIActivityTypePostToWeibo,
//                                        UIActivityTypeMessage,
//                                        UIActivityTypeMail,
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
