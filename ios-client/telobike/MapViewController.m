//
//  MapViewController.m
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MapViewController.h"
#import "City.h"
#import "StationList.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "RMMapContents.h"
#import "RMProjection.h"
#import "StationTableViewCell.h"
#import "RMYahooMapSource.h"
#import "Utils.h"
#import "ReportProblem.h"
#import "NavigateToStation.h"

@interface RMMarker (Station)

@property (nonatomic, retain) Station* station;

@end

@interface MapViewController (Private)

- (void)refreshStationsWithError:(BOOL)showError;
- (void)hideOpenedMarker;
- (RMMarker*)markerForStation:(Station*)station;

- (void)populateDetails;
- (void)hideDetailsPaneAnimated:(BOOL)animated;
- (void)showDetailsPaneForMarker:(RMMarker*)marker;
- (void)reloadStations;

- (void)locationChanged:(NSNotification*)n;

@end

@implementation MapViewController

@synthesize mapView=_mapView;
@synthesize detailsPane=_detailsPane;
@synthesize myLocationButton=_myLocationButton;

@synthesize availBikeLabel=_availBikeLabel;
@synthesize availParkLabel=_availParkLabel;
@synthesize bikeBox=_bikeBox;
@synthesize parkBox=_parkBox;
@synthesize stationName=_stationName;
@synthesize navigateToStationButton=_navigateToStationButton;
@synthesize reportProblemButton=_reportProblemButton;
@synthesize stationDistanceLabel=_stationDistanceLabel;
@synthesize stationBoxesPanel=_stationBoxesPanel;
@synthesize inactiveStationLabel=_inactiveStationLabel;
@synthesize delegate=_delegate;

- (void)dealloc
{
    [[AppDelegate app] removeLocationChangeObserver:self];
    
    [_stationBoxesPanel release];
    [_inactiveStationLabel release];
    [_stationDistanceLabel release];
    [_navigateToStationButton release];
    [_reportProblemButton release];
    [_availBikeLabel release];
    [_availParkLabel release];
    [_bikeBox release];
    [_parkBox release];
    [_stationName release];
    [_myLocationButton release];
    [_detailsPane release];
    [_openMarker release];
    [_mapView release];
    [_myLocation release];
    [_markers release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    [RMMapView class]; // needed to avoid: 'Interface builder does not recognize RMMapView'
    [super viewDidLoad];

    _markers = [NSMutableDictionary new];

    [_navigateToStationButton setTitle:NSLocalizedString(@"STATION_BUTTON_NAVIGATE", nil) forState:UIControlStateNormal];
    [_reportProblemButton setTitle:NSLocalizedString(@"STATION_BUTTON_REPORT", nil) forState:UIControlStateNormal];
    
    _inactiveStationLabel.text = NSLocalizedString(@"Inactive station", nil);

    [[AppDelegate app] addLocationChangeObserver:self selector:@selector(locationChanged:)];
    
    self.navigationItem.title = NSLocalizedString(@"Map", @"title of map view");
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    _myLocationButton.hidden = YES;

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(openList:)] autorelease];
    
    _mapView.delegate = self;
    
    // center tel-aviv
    [_mapView moveToLatLong:[City instance].cityCenter.coordinate];
    
    [self reloadStations];

    [self hideDetailsPaneAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadStations];
    
    // if we have a location from the location manager, add 'my location' now.
    [self locationChanged:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self hideOpenedMarker];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark RMMapViewDelegate

- (void) beforeMapMove: (RMMapView*) map
{
  [self hideDetailsPaneAnimated:YES];
}

- (void) tapOnLabelForMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
  [self hideOpenedMarker];
}

- (void)tapOnMarker:(RMMarker*)marker onMap:(RMMapView*)map
{
    // don't do anything if the marker is my location.
    if (marker == _myLocation) return;
  
    [self hideOpenedMarker];
  
    marker.zPosition = 999;
    [marker showLabel];
    [self showDetailsPaneForMarker:marker];
}

- (void)singleTapOnMap:(RMMapView*)map At:(CGPoint)point
{
    [self hideOpenedMarker];
}

- (void)selectStation:(Station*)station
{
    [self view]; // load nib
    
    [self hideOpenedMarker];
    
    if ([station isMyLocation])
    {
        [self showMyLocation:nil];
        return;
    }
    
    RMMarker* marker = [self markerForStation:station];
    if (!marker) return;

    // move map to show station
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(station.coords.latitude + 0.002, station.coords.longitude);
    [_mapView moveToLatLong:coords];
    [_mapView contents].zoom = 15;

    // simulate tap
    [self tapOnMarker:marker onMap:_mapView];
}

#pragma mark IBActions

- (IBAction)showMyLocation:(id)sender
{
    CLLocation* loc = [[AppDelegate app] currentLocation];
    if (!loc) return;
    
    [self hideDetailsPaneAnimated:YES];
    [_mapView moveToLatLong:loc.coordinate];
    [_mapView contents].zoom = 16;
}


- (IBAction)refresh:(id)sender
{
    [self refreshStationsWithError:YES];
}

- (IBAction)navigateToStation:(id)sender
{
    NavigateToStation* n = [[NavigateToStation new] autorelease];
    n.viewController = self;
    n.station = _openMarker.station;
    
    [n show];
}

- (IBAction)reportProblemInStation:(id)sender
{
    ReportProblem* r = [[[ReportProblem alloc] initWithParent:self station:_openMarker.station] autorelease];
    [r show];
}

#pragma mark - List

- (void)openList:(id)sender
{
    [_delegate mapViewControllerDidSelectList:self];
}

@end

@implementation RMMarker (Station)

- (void)setStation:(Station*)station
{
    self.data = station;
}

- (Station*)station
{
    return (Station*)self.data;
}

@end

@implementation MapViewController (Private)

- (void)hideOpenedMarker
{
    if (_openMarker)
    {
        Station* station = [_openMarker station];
        _openMarker.zPosition = [station isActive];
        UIImage* image = [station markerImage];
        CGPoint anchorPoint = CGPointMake(16.0 / (double)image.size.width, 35.0 / (double)image.size.height);
        [_openMarker replaceUIImage:image anchorPoint:anchorPoint];
        [_openMarker hideLabel];
        [_openMarker release];
        _openMarker = nil;
        
        [self hideDetailsPaneAnimated:YES];
    }
}

- (RMMarker*)markerForStation:(Station*)station
{
    return [_markers objectForKey:[station sid]];
}

- (void)hideDetailsPaneAnimated:(BOOL)animated
{
    if (animated) [UIView beginAnimations:nil context:nil];
    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, -_detailsPane.frame.size.height, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
    _detailsPane.hidden = NO;
    if (animated) [UIView commitAnimations];
    [self hideOpenedMarker];
}

- (UIImage*)imageForAvailability:(NSInteger)avail
{
    if (avail == 0) return [UIImage imageNamed:@"redbox.png"];
    return [UIImage imageNamed:@"greenbox.png"];
}

- (void)showDistanceForStation
{
    CLLocation* currentLocation = [[AppDelegate app] currentLocation];
    
    if (!currentLocation)
    {
        _stationDistanceLabel.hidden = YES;
        return;
    }
    
    _stationDistanceLabel.hidden = NO;
    CLLocationDistance distance = [_openMarker.station distanceFromLocation:currentLocation];
    _stationDistanceLabel.text = [Utils formattedDistance:distance];
}

- (void)populateDetails
{
    if (!_openMarker) return;
    
    BOOL showBoxes = _openMarker.station.isActive && _openMarker.station.isOnline;
    
    _stationBoxesPanel.hidden = !showBoxes;
    _inactiveStationLabel.hidden = showBoxes;
    _inactiveStationLabel.text = _openMarker.station.statusText;
    
    _stationName.text = _openMarker.station.stationName;
    _availBikeLabel.text = [NSString stringWithFormat:@"%d", [_openMarker.station availBike]];
    _availParkLabel.text = [NSString stringWithFormat:@"%d", [_openMarker.station availSpace]];
    
    [self showDistanceForStation];
    
    // set the color of the boxes based on the amount of avail bike/park
    _parkBox.image = [self imageForAvailability:[_openMarker.station availSpace]];
    _bikeBox.image = [self imageForAvailability:[_openMarker.station availBike]];
}

- (void)showDetailsPaneForMarker:(RMMarker*)marker
{
    [self hideDetailsPaneAnimated:NO];

    [_openMarker release];
    _openMarker = [marker retain];
    [self populateDetails];
    
    [UIView beginAnimations:nil context:nil];
    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, -5.0, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
    [UIView commitAnimations];
}

- (void)reloadStations
{
    RMMarkerManager* markerManager = [_mapView markerManager];
    
    // load stations
    NSArray* stations = [StationList instance].stations;
    
    for (Station* station in stations)
    {
        if ([station isMyLocation]) continue; // do not display the 'my location' station.
        
        UIImage* image = [station markerImage];
        CGPoint anchorPoint = CGPointMake(16.0 / (double)image.size.width, 35.0 / (double)image.size.height);
        
        // try to find an existing marker for this station
        RMMarker* marker = [self markerForStation:station];
        
        // if we couldn't find the marker, create it.
        if (!marker) 
        {
            marker = [[[RMMarker alloc] initWithUIImage:image anchorPoint:anchorPoint] autorelease];
            marker.label = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SelectedMarker.png"]] autorelease];
            marker.label.frame = CGRectMake(-9, -9, marker.label.frame.size.width + 1, marker.label.frame.size.height + 1);
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
    
    [self populateDetails];
}

- (void)locationChanged:(NSNotification*)n
{
    CLLocation* newLocation = [[AppDelegate app] currentLocation];
    
    if (!newLocation) return;
    
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

- (void)refreshStationsWithError:(BOOL)showError
{
    [[StationList instance] refreshStationsWithCompletion:^
     {
         [self reloadStations];
     } failure:^
     {
         if (showError)
         {
             [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", nil) message:NSLocalizedString(@"REFRESH_ERROR", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"REFRESH_ERROR_BUTTON", nil) otherButtonTitles:nil] autorelease] show];
         }
     } useCache:!showError];
}

@end
