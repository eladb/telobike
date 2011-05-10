//
//  MapViewController.h
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RMMapView.h"

@class RMMarker;

@interface MapViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate> {
    RMMarker* _openMarker;
    RMMarker* _myLocation;
    NSDictionary* _selectWhenViewAppears;
    CLLocationManager* _locationManager;
    BOOL visible;
}

@property (nonatomic, retain) IBOutlet RMMapView* mapView;

- (void)selectStation:(NSDictionary*)station;

@end
