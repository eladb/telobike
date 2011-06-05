//
//  MapViewController.m
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"
#import "City.h"
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

@property (nonatomic, retain) NSDictionary* station;

@end

@interface MapViewController (Private)

- (void)hideOpenedMarker;
- (RMMarker*)markerForStation:(NSDictionary*)station;

- (void)hideDetailsPane;
- (void)showDetailsPane;
- (void)reloadStations;


@end

@implementation MapViewController

@synthesize mapView=_mapView;
@synthesize detailsPane=_detailsPane;
@synthesize myLocationButton=_myLocationButton;

- (void)dealloc
{
    [_myLocationButton release];
    [_calloutView release];
    [_detailsPane release];
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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    _myLocationButton.hidden = YES;
    
    _mapView.delegate = self;
    
    // center tel-aviv
    [_mapView moveToLatLong:[City instance].cityCenter.coordinate];
    
    _calloutView = [[StationCalloutView alloc] init];
    _calloutView.view.frame = _detailsPane.bounds;
    _calloutView.parentController = self;
    
    UIColor* tintColor = self.navigationController.navigationBar.tintColor;
    if (tintColor)
    {
        _calloutView.view.backgroundColor = [tintColor colorWithAlphaComponent:0.7];
    }
    
    
    [_detailsPane addSubview:_calloutView.view];
    
    [self hideDetailsPane];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    visible = YES;
    
    [self reloadStations];
    
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
    [self hideOpenedMarker];
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
    _calloutView.station = marker.station;
    
    [self showDetailsPane];
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
    [_mapView contents].zoom = 15;

    // simulate tap
    [self tapOnMarker:marker onMap:_mapView];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!_myLocation) 
    {
        _myLocation = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"MyLocation.png"] anchorPoint:CGPointMake(0.5, 0.5)];
        _myLocation.zPosition = 9999;
        RMProjection* proj = [_mapView markerManager].contents.projection;
        [[_mapView markerManager] addMarker:_myLocation atProjectedPoint:[proj latLongToPoint:newLocation.coordinate]];
    }
    else 
    {
        [[_mapView markerManager] moveMarker:_myLocation AtLatLon:newLocation.coordinate];
    }
    
    _myLocationButton.hidden = NO;
}

#pragma mark IBActions

- (IBAction)showMyLocation:(id)sender
{
    if (!_locationManager.location) return;
    [_mapView moveToLatLong:_locationManager.location.coordinate];
}


- (IBAction)refresh:(id)sender
{
    [[StationList instance] refreshStationsWithCompletion:^
     {
         [self reloadStations];
     }];
}

@end

@implementation RMMarker (Station)

- (void)setStation:(NSDictionary*)station
{
    self.data = station;
}

- (NSDictionary*)station
{
    return (NSDictionary*)self.data;
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
        
        [self hideDetailsPane];
    }
}

- (RMMarker*)markerForStation:(NSDictionary*)station
{
    return [_markers objectForKey:[station sid]];
}

- (void)hideDetailsPane
{
    [UIView beginAnimations:nil context:nil];
    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, -_detailsPane.frame.size.height, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
    _detailsPane.hidden = NO;
    [UIView commitAnimations];
}

- (void)showDetailsPane
{
    [self hideDetailsPane];
//    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, -_detailsPane.frame.size.height, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
//    _detailsPane.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, 0, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
    [UIView commitAnimations];
}

- (void)reloadStations
{
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
            marker.label = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cycling.png"]] autorelease];
            marker.zPosition = [station isActive];
            [marker hideLabel];
            RMProjection* proj = markerManager.contents.projection;
            [markerManager addMarker:marker atProjectedPoint:[proj latLongToPoint:[station coords]]];
            [_markers setValue:marker forKey:[station sid]];
        }
        
        // update station.
        marker.data = station;
        [marker replaceUIImage:image anchorPoint:anchorPoint];
    }
}

@end
