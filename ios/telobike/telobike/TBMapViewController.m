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
#import "TBCalloutAccessoryView.h"
#import "NSBundle+View.h"
#import "TBNavigationController.h"

@interface TBMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) TBServer* server;

@end

@implementation TBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.server = [TBServer instance];
    
    [self observeValueOfKeyPath:@"stations" object:self.server with:^(id new, id old) {
        [self refresh:nil];
        self.selectedStation = self.selectedStation;
    }];
    
    [self observeValueOfKeyPath:@"city" object:self.server with:^(id new, id old) {
        if (self.selectedStation) {
            // if we have a selected station, don't update the region
            return;
        }
        
        MKCoordinateRegion region;
        region.center = self.server.city.cityCenter.coordinate;
        region.span = MKCoordinateSpanMake(0.05, 0.05);
        [self.mapView setRegion:region animated:NO];
    }];
    
    MKUserTrackingBarButtonItem* trackingBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.rightBarButtonItem = trackingBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    navigationController.tabBar.selectedItem = navigationController.mapViewController.tabBarItem;
}

- (void)refresh:(id)sender {
    // create a dictionary of existing annotations to update
    NSMutableDictionary* existingAnnotations = [[NSMutableDictionary alloc] init];
    for (TBStation* existingStation in _mapView.annotations) {
        if (![existingStation isKindOfClass:[TBStation class]]) {
            continue; // skip MKUserLocation annotation
        }
        [existingAnnotations setObject:existingStation forKey:existingStation.sid];
    }
    
    for (TBStation* station in [TBServer instance].stations) {
        TBStation* existingStation = [existingAnnotations objectForKey:station.sid];
        if (existingStation) {
            // station already exists, just update
            existingStation.dict = station.dict;
        }
        else {
            // station does not exist, add
            [self.mapView addAnnotation:station];
        }
    }
}

#pragma mark - Selection

- (void)setSelectedStation:(TBStation *)selectedStation {
    TBStation* prev = _selectedStation;
    _selectedStation = selectedStation;

    for (TBStation* station in self.mapView.annotations) {
        if (![station isKindOfClass:[TBStation class]]) {
            continue;
        }
        
        if ([station.sid isEqualToString:selectedStation.sid]) {
            [self.mapView deselectAnnotation:prev animated:NO];

            MKCoordinateRegion region;
            region.span = MKCoordinateSpanMake(0.02, 0.02);
            region.center = station.coordinate;
            [self.mapView setRegion:region animated:YES];
            [self.mapView selectAnnotation:station animated:YES];

            break; // break loop
        }
    }
}

#pragma mark - Map view delegate

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
        TBCalloutAccessoryView* a = [[NSBundle mainBundle] loadViewFromNibForClass:[TBCalloutAccessoryView class]];
        a.autoresizingMask = 0;
        view.leftCalloutAccessoryView = a;
    }
    
    TBStation* station = (TBStation*)annotation;
    view.image = station.markerImage;
    view.canShowCallout = YES;
    TBCalloutAccessoryView* a = (TBCalloutAccessoryView*)view.leftCalloutAccessoryView;
    a.station = station;

    return view;
}

@end
