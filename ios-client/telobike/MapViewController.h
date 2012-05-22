//
//  MapViewController.h
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Station.h"

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate> {
    NSMutableDictionary* _markers;
    NSMutableDictionary* _annotations;
}

@property (nonatomic, assign) id<MapViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView* map;
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
@property (nonatomic, retain) IBOutlet UIButton* favoriteButton;
@property (nonatomic, retain) IBOutlet UILabel* stationDistanceLabel;
@property (nonatomic, retain) IBOutlet UIView* stationBoxesPanel;
@property (nonatomic, retain) IBOutlet UILabel* inactiveStationLabel;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;

- (void)selectStation:(Station*)station;
- (IBAction)showMyLocation:(id)sender;
- (IBAction)refresh:(id)sender;

// station actions
- (IBAction)navigateToStation:(id)sender;
- (IBAction)reportProblemInStation:(id)sender;
- (IBAction)toggleFavorite:(id)sender;

@end

@protocol MapViewControllerDelegate <NSObject>

@required
- (void)mapViewControllerDidSelectList:(MapViewController*)viewController;

@end

@interface StationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) Station* station;

- (id)initWithStation:(Station*)s;

@end
