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
    RMMarker* _myLocation;
    NSMutableDictionary* _markers;
}

@property (nonatomic, retain) IBOutlet RMMapView* mapView;
@property (nonatomic, retain) IBOutlet UIButton* myLocationButton;

// details pane
@property (nonatomic, retain) IBOutlet UIView* detailsPane;
@property (nonatomic, retain) IBOutlet UILabel* availBikeLabel;
@property (nonatomic, retain) IBOutlet UILabel* availParkLabel;
@property (nonatomic, retain) IBOutlet UIImageView* bikeBox;
@property (nonatomic, retain) IBOutlet UIImageView* parkBox;
@property (nonatomic, retain) IBOutlet UILabel* stationName;
@property (nonatomic, retain) IBOutlet UIButton* navigateToStationButton;
@property (nonatomic, retain) IBOutlet UIButton* reportProblemButton;
@property (nonatomic, retain) IBOutlet UILabel* stationDistanceLabel;
@property (nonatomic, retain) IBOutlet UIView* stationBoxesPanel;
@property (nonatomic, retain) IBOutlet UILabel* inactiveStationLabel;

- (void)selectStation:(NSDictionary*)station;
- (IBAction)showMyLocation:(id)sender;
- (IBAction)refresh:(id)sender;

// station actions
- (IBAction)navigateToStation:(id)sender;
- (IBAction)reportProblemInStation:(id)sender;

@end

