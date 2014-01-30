//
//  TBPlacemarkAnnotation.h
//  telobike
//
//  Created by Elad Ben-Israel on 12/8/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVGeocoder/SVPlacemark.h>
@import MapKit;

@interface TBPlacemarkAnnotation : NSObject <MKAnnotation>

@property (strong, readonly) SVPlacemark* placemark;

- (id)initWithPlacemark:(SVPlacemark*)placemark;

@end
