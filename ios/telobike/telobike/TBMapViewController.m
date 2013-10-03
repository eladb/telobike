//
//  TBSecondViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "TBStation.h"
#import "TBMapViewController.h"
#import "TBServer.h"
#import "NSObject+Binding.h"
#import "NSBundle+View.h"
#import "TBNavigationController.h"
#import "TBStationViewController.h"
#import "TBStationDetailsView.h"

@interface TBMapViewController () <GMSMapViewDelegate>


@property (strong, nonatomic) IBOutlet GMSMapView* gmapView;
@property (strong, nonatomic) IBOutlet UIView*     stationDetailsContainerView;

@property (strong, nonatomic) TBServer* server;

@property (strong, nonatomic) NSMutableDictionary*  markers;
@property (strong, nonatomic) TBStationDetailsView* stationDetails;
@property (assign) BOOL doNotHide;

@end

@implementation TBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.markers = [[NSMutableDictionary alloc] init];
    self.server = [TBServer instance];
    
    [self observeValueOfKeyPath:@"stations" object:self.server with:^(id new, id old) {
        [self refresh:nil];
    }];
    
    [self observeValueOfKeyPath:@"city" object:self.server with:^(id new, id old) {
        // if we have a selected station, don't update the region
        if (self.selectedStation) {
            return;
        }

        self.gmapView.camera = [GMSCameraPosition cameraWithTarget:self.server.city.cityCenter.coordinate zoom:13];
    }];
    
    // google maps
    self.gmapView.camera                    = [GMSCameraPosition cameraWithTarget:self.server.city.cityCenter.coordinate zoom:13];
    self.gmapView.myLocationEnabled         = YES;
    self.gmapView.settings.myLocationButton = YES;
    self.gmapView.settings.compassButton    = YES;
    self.gmapView.padding = UIEdgeInsetsMake(64.0f, 0.0f, 49.0f, 0.0f);
    self.gmapView.delegate = self;
    
    // station details
    self.stationDetails = [[NSBundle mainBundle] loadViewFromNibForClass:[TBStationDetailsView class]];
    CGRect stationDetailsContainerFrame = self.stationDetailsContainerView.frame;
    stationDetailsContainerFrame.size.height = self.stationDetails.frame.size.height + 49.0f;
    self.stationDetailsContainerView.frame = stationDetailsContainerFrame;
    [self.stationDetailsContainerView addSubview:self.stationDetails];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews, selectedStation:%@", self.selectedStation ? self.selectedStation.sid : @"nil");
    [super viewDidLayoutSubviews];
    if (!self.doNotHide) {
        [self hideStationDetailsAnimated:NO];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    navigationController.tabBar.selectedItem = navigationController.mapViewController.tabBarItem;
    
    [self refresh:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
    self.doNotHide = NO;
}

- (void)refresh:(id)sender {
    for (TBStation* station in [TBServer instance].stations) {
        
        // if a marker exists for this station id, reuse it
        GMSMarker* marker = [self.markers objectForKey:station.sid];
        if (!marker) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            [self.markers setObject:marker forKey:station.sid];
        }
        
        marker.position = station.coordinate;
        marker.map = self.gmapView;
        marker.title = station.title;
        marker.snippet = station.subtitle;
        marker.icon = station.markerImage;
        marker.userData = station;
    }
}

#pragma mark - Selection

- (void)setSelectedStation:(TBStation *)selectedStation {
    NSLog(@"setSelectedStation:%@", selectedStation ? selectedStation.sid : @"nil");

    if (_selectedStation == selectedStation) {
        return; // nothing to do
    }
    
    // hide details of previous station
    if (_selectedStation) {
        [self hideStationDetailsAnimated:YES];
    }
    
    _selectedStation = selectedStation;

    // no station is selected so we are done now
    if (!selectedStation) {
        return;
    }

    // move camera to make selected station visible (details will open after camera is idle)
    GMSCameraPosition* pos = [GMSCameraPosition cameraWithTarget:selectedStation.coordinate zoom:15];
    [self.gmapView animateToCameraPosition:pos];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    self.selectedStation = marker.userData;
    return YES;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if (gesture) {
        self.selectedStation = nil;
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"idleAtCameraPosition, selectedStation:%@", self.selectedStation  ? self.selectedStation.sid : @"nil");
    if (self.selectedStation) {
        self.doNotHide = YES;
        self.stationDetails.station = self.selectedStation;
        [self showStationDetailsAnimated:YES];
    }
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
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            self.stationDetailsContainerView.frame = newFrame;
        }];
    }
    else {
        self.stationDetailsContainerView.frame = newFrame;
    }
}

@end