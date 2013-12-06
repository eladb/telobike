//
//  TBSecondViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
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
#import "TBStationAnnotationView.h"
#import "TBStationActivityViewController.h"

@interface TBMapViewController () <MKMapViewDelegate, TBStationDetailsViewDelegate>

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
    self.stationDetails.stationDetailsDelegate = self;
//    CGRect stationDetailsFrame = self.stationDetails.frame;
//    stationDetailsFrame.origin.y = 64.0;
//    self.stationDetails.frame = stationDetailsFrame;

//    UIToolbar* tb = [[UIToolbar alloc] initWithFrame:self.stationDetailsContainerView.bounds];
//    tb.barTintColor = [UIColor detailsBackgroundColor];
//    [self.stationDetailsContainerView addSubview:tb];
    self.stationDetailsContainerView.backgroundColor = [UIColor detailsBackgroundColor];
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
//    self.selectedStation = nil;
}

#pragma mark - Annotations

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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* identifier = @"station";
    
    // only if this is a station annotation
    if (![annotation isKindOfClass:[TBStation class]]) {
        return nil;
    }
    
    MKAnnotationView* view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!view) {
        view = [[TBStationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    return view;
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
    for (id annoation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:annoation animated:YES];
    }

    // hide details of previous station
    if (_selectedStation) {
        [self hideStationDetailsAnimated:YES];
    }
    
    _selectedStation = selectedStation;
    [self.mapView selectAnnotation:selectedStation animated:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self hideStationDetailsAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    _selectedStation = (TBStation*)view.annotation;

    self.stationDetails.station = (TBStation*)view.annotation;
    [self showStationDetailsAnimated:YES];
    
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.004, 0.004);
    region.center = self.selectedStation.coordinate;
    
    self.regionChangingForSelection = YES;
    [self.mapView setRegion:region animated:YES];
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
    stationDetailsFrame.origin.y = -self.stationDetailsContainerView.frame.size.height;
    [self changeStationDetailsFrame:stationDetailsFrame animated:animated];
}

- (void)showStationDetailsAnimated:(BOOL)animated {
    CGRect stationDetailsFrame = self.stationDetailsContainerView.frame;
    stationDetailsFrame.origin.y = 64.0f;
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

- (void)stationDetailsActionClicked:(TBStationDetailsView *)detailsView {
    TBStationActivityViewController* vc = [[TBStationActivityViewController alloc] initWithStation:detailsView.station];
    vc.completionHandler = ^(NSString* activityName, BOOL completed){
        NSLog(@"completed with %@", activityName);
    };
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - My location

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"ERROR: unable to determine location: %@", error);
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
