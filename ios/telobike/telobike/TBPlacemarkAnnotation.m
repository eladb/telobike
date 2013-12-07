//
//  TBPlacemarkAnnotation.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/8/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBPlacemarkAnnotation.h"

@interface TBPlacemarkAnnotation ()

@property (strong, nonatomic) SVPlacemark* placemark;

@end

@implementation TBPlacemarkAnnotation

- (id)initWithPlacemark:(SVPlacemark *)placemark {
    self = [super init];
    if (self) {
        self.placemark = placemark;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return self.placemark.coordinate;
}

@end
