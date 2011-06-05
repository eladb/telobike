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
#import "StationCalloutView.h"

@class RMMarker;

@interface MapViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate> {
    RMMarker* _openMarker;
    RMMarker* _myLocation;
    NSDictionary* _selectWhenViewAppears;
    NSMutableDictionary* _markers;
    CLLocationManager* _locationManager;
    StationCalloutView* _calloutView;
    BOOL visible;
}

@property (nonatomic, retain) IBOutlet RMMapView* mapView;
@property (nonatomic, retain) IBOutlet UIView* detailsPane;
@property (nonatomic, retain) IBOutlet UIButton* myLocationButton;

- (void)selectStation:(NSDictionary*)station;
- (IBAction)showMyLocation:(id)sender;
- (IBAction)refresh:(id)sender;

@end
