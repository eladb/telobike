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

@interface RMMarker (Station)

- (StationCalloutView*)callout;
- (NSDictionary*)station;

@end

@interface MapViewController (Private)

- (void)hideOpenedMarker;
- (RMMarker*)markerForStation:(NSDictionary*)station;

@end

@implementation MapViewController

@synthesize mapView=_mapView;

- (void)dealloc
{
    [_selectedStation release];
    [_openMarker release];
    [_mapView release];
    [_myLocation release];
    [_locationManager release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [RMMapView class]; // needed to avoid: 'Interface builder does not recognize RMMapView'

    [super viewDidLoad];
    
    _locationManager = [CLLocationManager new];
    [_locationManager startUpdatingLocation];
    _locationManager.delegate = self;

    self.navigationItem.title = @"מפה";
    _mapView.delegate = self;
    [_mapView moveToLatLong:CLLocationCoordinate2DMake(32.069629,34.777222)];

    
    RMMarkerManager* markerManager = [_mapView markerManager];
    
    // load stations
    NSArray* stations = [StationList instance].stations;
    
    for (NSDictionary* station in stations)
    {
        UIImage* image = [station markerImage];
        CGPoint anchorPoint = CGPointMake(16.0 / (double)image.size.width, 35.0 / (double)image.size.height);
        RMMarker* marker = [[[RMMarker alloc] initWithUIImage:image anchorPoint:anchorPoint] autorelease];
        
        StationCalloutView* label = [[StationCalloutView new] autorelease];
        label.view.frame = CGRectMake(-85-16, -100, label.view.frame.size.width, label.view.frame.size.height);
        marker.data = label;
        marker.label = label.view;
        marker.zPosition = [station isActive];

        label.station = station;
        
        [marker hideLabel];
        RMProjection* proj = markerManager.contents.projection;
        [markerManager addMarker:marker atProjectedPoint:[proj latLongToPoint:[station coords]]];
    }
    
    if (_selectedStation)
    {
        [self selectStation:_selectedStation];
    }
}

#pragma mark RMMapViewDelegate

- (void)tapOnMarker:(RMMarker*)marker onMap:(RMMapView*)map
{
    // don't do anything if the marker is my location.
    if (marker == _myLocation) return;
    
    [self hideOpenedMarker];

    marker.zPosition = 999;
    [marker replaceUIImage:nil];
    
    [marker showLabel];
    _openMarker = [marker retain];
}

- (void)singleTapOnMap:(RMMapView*)map At:(CGPoint)point
{
    [self hideOpenedMarker];
}

- (void)selectStation:(NSDictionary*)station
{
    [_selectedStation release];
    _selectedStation = nil;

    // if map view was not initialized yet, we just reain the station and get back here
    // from viewDidLoad.
    if (!_mapView)
    {
        _selectedStation = [station retain];
        return;
    }
    
    [self hideOpenedMarker];
    
    RMMarker* marker = [self markerForStation:station];
    if (!marker) return;

    // move map to current location or marker (if we don't have current location)
    if (_locationManager.location)
    {
        [_mapView moveToLatLong:_locationManager.location.coordinate];
    }
    else
    {
        [_mapView moveToLatLong:[station coords]];
    }
    
    [_mapView contents].zoom = 17;

    // simulate tap
    [self tapOnMarker:marker onMap:_mapView];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!_myLocation) 
    {
        _myLocation = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"myLocation.png"] anchorPoint:CGPointMake(0.5, 0.5)];
        RMProjection* proj = [_mapView markerManager].contents.projection;
        [[_mapView markerManager] addMarker:_myLocation atProjectedPoint:[proj latLongToPoint:newLocation.coordinate]];
    }
    else 
    {
        [[_mapView markerManager] moveMarker:_myLocation AtLatLon:newLocation.coordinate];
    }
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
    // find station to select by iterating the markers
    for (RMMarker* marker in _mapView.markerManager.markers)
    {
        NSDictionary* markerStation = [marker station];
        
        if ([[markerStation stationName] isEqualToString:[station stationName]]) 
        {
            // found it
            return marker;
        }
    }
    
    return nil;
}

@end
