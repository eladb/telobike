//
//  TBSecondViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TBStation.h"
#import "TBMapViewController.h"
#import "TBServer.h"
#import "NSObject+Binding.h"
#import "UIColor+Style.h"
#import "NSBundle+View.h"
#import "TBNavigationController.h"
#import "TBStationViewController.h"
#import "TBStationDetailsView.h"
#import "KMLParser.h"

@interface TBMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UIView*    stationDetailsContainerView;

@property (strong, nonatomic) TBServer* server;
@property (strong, nonatomic) NSMutableDictionary*  markers;
@property (strong, nonatomic) TBStationDetailsView* stationDetails;
@property (strong, nonatomic) KMLParser* kmlParser;

@property (assign, nonatomic) BOOL regionChangingForSelection;

@end

@implementation TBMapViewController

#pragma mark - View controller events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.markers = [[NSMutableDictionary alloc] init];
    self.server = [TBServer instance];
    
    [self observeValueOfKeyPath:@"stations" object:self.server with:^(id new, id old) {
        [self refresh:nil];
        self.selectedStation = self.selectedStation;
    }];
    
    [self observeValueOfKeyPath:@"city" object:self.server with:^(id new, id old) {
        // if we have a selected station, don't update the region
        if (self.selectedStation) {
            return;
        }
        
        MKCoordinateRegion region;
        region.center = self.server.city.cityCenter.coordinate;
        region.span = MKCoordinateSpanMake(0.05, 0.05);
        [self.mapView setRegion:region animated:NO];
    }];
    
    MKUserTrackingBarButtonItem* trackingBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.rightBarButtonItem = trackingBarButtonItem;
    
    
    // station details
    self.stationDetails = [[NSBundle mainBundle] loadViewFromNibForClass:[TBStationDetailsView class]];
    CGRect stationDetailsContainerFrame = self.stationDetailsContainerView.frame;
    stationDetailsContainerFrame.size.height = self.stationDetails.frame.size.height + 49.0f;
    
//    CGRect stationDetailsFrame = self.stationDetails.frame;
//    stationDetailsFrame.size.height = stationDetailsContainerFrame.size.height;
//    self.stationDetails.frame =stationDetailsFrame;
    
    self.stationDetailsContainerView.frame = stationDetailsContainerFrame;
    self.stationDetailsContainerView.backgroundColor = [UIColor barDimColor];
    [self.stationDetailsContainerView addSubview:self.stationDetails];
    
    [self loadRoutesFromKML];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    static BOOL oneOff = YES;
    if (oneOff || !self.selectedStation) {
        [self hideStationDetailsAnimated:NO];
        oneOff = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    navigationController.tabBar.selectedItem = navigationController.mapViewController.tabBarItem;
    
    [self refresh:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.selectedStation = nil;
}

#pragma mark - Markers

- (void)refresh:(id)sender {
    for (TBStation* station in [TBServer instance].stations) {
        
        // if a marker exists for this station id, reuse it
        TBStation* existingMarker = [self.markers objectForKey:station.sid];
        if (existingMarker) {
            existingMarker.dict = station.dict;
            continue;
        }
        
        // add annotation to map (and dictionary)
        [self.mapView addAnnotation:station];
        [self.markers setObject:station forKey:station.sid];
    }
}

#pragma mark - Selection

- (void)setSelectedStation:(TBStation *)selectedStation {
    // look for annotation based on sid
    for (TBStation* annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:[TBStation class]]) {
            continue; // skip other annotations
        }
        
        if ([annotation.sid isEqualToString:selectedStation.sid]) {
            selectedStation = annotation;
        }
    }
    
    // deselect any annotations
    self.mapView.selectedAnnotations = nil;

    // hide details of previous station
    if (_selectedStation) {
        [self hideStationDetailsAnimated:YES];
    }
    
    _selectedStation = selectedStation;
    
    self.mapView.selectedAnnotations = nil;
    [self.mapView selectAnnotation:selectedStation animated:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self hideStationDetailsAnimated:YES];

    view.image = ((TBStation*)view.annotation).markerImage;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    _selectedStation = (TBStation*)view.annotation;

    self.stationDetails.station = (TBStation*)view.annotation;
    [self showStationDetailsAnimated:YES];

    view.image = _selectedStation.selectedMarkerImage;
    
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.004, 0.004);
    region.center = self.selectedStation.coordinate;
    
    self.regionChangingForSelection = YES;
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* identifier = @"station";
    
    // only if this is a station annotation
    if (![annotation isKindOfClass:[TBStation class]]) {
        return nil;
    }
    
    MKAnnotationView* view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        view.centerOffset = CGPointMake(6.0, -18.0);
    }
    
    TBStation* station = (TBStation*)annotation;
    view.image = station.markerImage;

    return view;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (self.regionChangingForSelection) {
        return; // if region is changing for selection, do nothing
    }

    self.selectedStation = nil; // deselect station if user moves map
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.regionChangingForSelection = NO;
}

#pragma mark - Station details

- (void)hideStationDetailsAnimated:(BOOL)animated {
    CGRect stationDetailsFrame = self.stationDetailsContainerView.frame;
    stationDetailsFrame.origin.y = self.view.bounds.size.height;
    [self changeStationDetailsFrame:stationDetailsFrame animated:animated];
}

- (void)showStationDetailsAnimated:(BOOL)animated {
    CGRect stationDetailsFrame = self.stationDetailsContainerView.frame;
    stationDetailsFrame.origin.y = self.view.bounds.size.height - stationDetailsFrame.size.height;
    [self changeStationDetailsFrame:stationDetailsFrame animated:animated];
}

- (void)changeStationDetailsFrame:(CGRect)newFrame animated:(BOOL)animated {
    
    if (!self.parentViewController) {
        animated = NO;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            self.stationDetailsContainerView.frame = newFrame;
        }];
    }
    else {
        self.stationDetailsContainerView.frame = newFrame;
    }
}

#pragma mark - My location

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", @"Title of alert view")
                                message:NSLocalizedString(@"Unable to determine location", @"Location error message")
                               delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Cancel button for location erro alert")
                      otherButtonTitles:nil] show];
}

#pragma mark - Routes

- (void)loadRoutesFromKML {
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"routes" withExtension:@"kml"];
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    [self.kmlParser parseKML];
    [self.mapView addOverlays:self.kmlParser.overlays];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [self.kmlParser rendererForOverlay:overlay];
}

@end
