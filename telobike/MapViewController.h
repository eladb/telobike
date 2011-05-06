//
//  MapViewController.h
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@class RMMarker;

@interface MapViewController : UIViewController <RMMapViewDelegate> {
    RMMarker* _openMarker;
    NSDictionary* _selectedStation;
}

@property (nonatomic, retain) IBOutlet RMMapView* mapView;

- (void)selectStation:(NSDictionary*)station;

@end
