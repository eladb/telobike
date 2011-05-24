//
//  MapViewController.m
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"
#import "StationList.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "RMMapContents.h"
#import "RMProjection.h"
#import "StationTableViewCell.h"
#import "StationCalloutView.h"
#import "NSDictionary+Station.h"
#import "RMYahooMapSource.h"

@interface RMMarker (Station)

- (StationCalloutView*)callout;
- (NSDictionary*)station;

@end

@interface MapViewController (Private)

- (void)hideOpenedMarker;
- (RMMarker*)markerForStation:(NSDictionary*)station;
- (void)showMyLocation:(id)sender;

@end

@implementation MapViewController

@synthesize mapView=_mapView;

- (void)dealloc
{
    [_selectWhenViewAppears release];
    [_openMarker release];
    [_mapView release];
    [_myLocation release];
    [_locationManager release];
    [_markers release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [RMMapView class]; // needed to avoid: 'Interface builder does not recognize RMMapView'
    [super viewDidLoad];

    _markers = [NSMutableDictionary new];

    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];

    self.navigationItem.title = NSLocalizedString(@"Map", @"title of map view");
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"My Position", @"my position button on map") 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:self action:@selector(showMyLocation:)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    
    _mapView.delegate = self;
    
    // center tel-aviv
    [_mapView moveToLatLong:[StationList instance].center];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    visible = YES;
    
    RMMarkerManager* markerManager = [_mapView markerManager];

    // load stations
    NSArray* stations = [StationList instance].stations;
    
    for (NSDictionary* station in stations)
    {
        UIImage* image = [station markerImage];
        CGPoint anchorPoint = CGPointMake(16.0 / (double)image.size.width, 35.0 / (double)image.size.height);
        
        // try to find an existing marker for this station
        RMMarker* marker = [self markerForStation:station];

        // if we couldn't find the marker, create it.
        if (!marker) 
        {
            marker = [[[RMMarker alloc] initWithUIImage:image anchorPoint:anchorPoint] autorelease];
            StationCalloutView* label = [[StationCalloutView new] autorelease];
            label.view.frame = CGRectMake(-85/*-16*/, -95, label.view.frame.size.width, label.view.frame.size.height);
            marker.data = label;
            marker.label = label.view;
            marker.zPosition = [station isActive];
            [marker hideLabel];
            RMProjection* proj = markerManager.contents.projection;
            [markerManager addMarker:marker atProjectedPoint:[proj latLongToPoint:[station coords]]];
            [_markers setValue:marker forKey:[station sid]];
        }

        // update station.
        ((StationCalloutView*)marker.data).station = station;
        [marker replaceUIImage:image anchorPoint:anchorPoint];
    }
    
    // if we have a location from the location manager, add 'my location' now.
    if (_locationManager.location) 
    {
        [self locationManager:_locationManager didUpdateToLocation:_locationManager.location fromLocation:nil];
    }

    // only used in the first load
    if (_selectWhenViewAppears)
    {
        NSLog(@"selecting station after view appears");
        [self selectStation:_selectWhenViewAppears];
        [_selectWhenViewAppears release];
        _selectWhenViewAppears = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    visible = NO;
}

#pragma mark RMMapViewDelegate

- (void)tapOnMarker:(RMMarker*)marker onMap:(RMMapView*)map
{
    // don't do anything if the marker is my location.
    if (marker == _myLocation) return;
    
    [self hideOpenedMarker];

    marker.zPosition = 999;
    
    [marker showLabel];
    _openMarker = [marker retain];
}

- (void)singleTapOnMap:(RMMapView*)map At:(CGPoint)point
{
    [self hideOpenedMarker];
}

- (void)selectStation:(NSDictionary*)station
{
    // if map view was not initialized yet, we just reain the station and get back here
    // from viewDidLoad.
    if (!visible)
    {
        _selectWhenViewAppears = [station retain];
        return;
    }
    
    [self hideOpenedMarker];
    
    RMMarker* marker = [self markerForStation:station];
    if (!marker) return;

    // move map to show station
    [_mapView moveToLatLong:[station coords]];
    [_mapView contents].zoom = 17;

    // simulate tap
    [self tapOnMarker:marker onMap:_mapView];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!_myLocation) 
    {
        _myLocation = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"MyLocation.png"] anchorPoint:CGPointMake(0.5, 0.5)];
        RMProjection* proj = [_mapView markerManager].contents.projection;
        [[_mapView markerManager] addMarker:_myLocation atProjectedPoint:[proj latLongToPoint:newLocation.coordinate]];
    }
    else 
    {
        [[_mapView markerManager] moveMarker:_myLocation AtLatLon:newLocation.coordinate];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end

@implementation RMMarker (Station)

- (StationCalloutView*)callout
{
    return (StationCalloutView*) self.data;
}

- (NSDictionary*)station
{
    return [self callout].station;
}

@end

@implementation MapViewController (Private)

- (void)hideOpenedMarker
{
    if (_openMarker)
    {
        NSDictionary* station = [_openMarker station];
        _openMarker.zPosition = [station isActive];
        UIImage* image = [station markerImage];
        CGPoint anchorPoint = CGPointMake(16.0 / (double)image.size.width, 35.0 / (double)image.size.height);
        [_openMarker replaceUIImage:image anchorPoint:anchorPoint];
        [_openMarker hideLabel];
        [_openMarker release];
        _openMarker = nil;
    }
}

- (RMMarker*)markerForStation:(NSDictionary*)station
{
    return [_markers objectForKey:[station sid]];
}

- (void)showMyLocation:(id)sender
{
    if (!_locationManager.location) return;
    [_mapView moveToLatLong:_locationManager.location.coordinate];
}

@end
