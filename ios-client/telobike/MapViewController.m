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
#import "Analytics.h"

@interface RMMarker (Station)

@property (nonatomic, retain) Station* station;

@end

@interface MapViewController (Private)

- (void)refreshStationsWithError:(BOOL)showError;

- (void)populateDetails;
- (void)hideDetailsPaneAnimated:(BOOL)animated;
- (void)showDetailsPane;
- (void)reloadStations;
- (Station*)selectedStation;
- (StationAnnotation*)annotationForStation:(Station*)s;

- (void)renderFavoriteButton;

@end

@implementation MapViewController

@synthesize detailsPane=_detailsPane;
@synthesize myLocationButton=_myLocationButton;
@synthesize map=_map;

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
@synthesize favoriteButton=_favoriteButton;
@synthesize searchBar=_searchBar;

- (void)dealloc
{
    [[AppDelegate app] removeLocationChangeObserver:self];
    
    [_searchBar release];
    [_favoriteButton release];
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
    [_map release];
    [_annotations release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _annotations = [NSMutableDictionary new];

    [_navigateToStationButton setTitle:NSLocalizedString(@"STATION_BUTTON_NAVIGATE", nil) forState:UIControlStateNormal];
    [_reportProblemButton setTitle:NSLocalizedString(@"STATION_BUTTON_REPORT", nil) forState:UIControlStateNormal];
    
    _inactiveStationLabel.text = NSLocalizedString(@"Inactive station", nil);
    
    self.navigationItem.title = NSLocalizedString(@"Map", @"title of map view");
    
    //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    _myLocationButton.hidden = YES;
//    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", nil) style:UIBarButtonItemStylePlain target:self action:@selector(openList:)] autorelease];
    
    MKCoordinateRegion region;
    region.center = [City instance].cityCenter.coordinate;
    region.span = MKCoordinateSpanMake(0.005, 0.005);
    [_map setRegion:region];
    
    _map.showsUserLocation = YES;
    
    [self reloadStations];

    [self hideDetailsPaneAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[Analytics shared] pageViewMap];
    [self reloadStations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark RMMapViewDelegate

//TODO:
//- (void) beforeMapMove: (RMMapView*) map
//{
//  [self hideDetailsPaneAnimated:YES];
//}
//

- (void)selectStation:(Station*)station
{
    [self view]; // load nib
    
    if ([station isMyLocation])
    {
        [self showMyLocation:nil];
        return;
    }
    
    id <MKAnnotation> ann = [self annotationForStation:station]; 
    [_map selectAnnotation:ann animated:NO];
}

#pragma mark IBActions

- (IBAction)showMyLocation:(id)sender
{
    [_map setCenterCoordinate:[_map userLocation].coordinate animated:YES];
    [_map deselectAnnotation:[[_map selectedAnnotations] objectAtIndex:0] animated:NO];
}

- (IBAction)refresh:(id)sender
{
    [self refreshStationsWithError:YES];
}

- (IBAction)navigateToStation:(id)sender
{
    NavigateToStation* n = [[NavigateToStation new] autorelease];
    n.viewController = self;
    n.station = [self selectedStation];
    [n show];
}

- (IBAction)reportProblemInStation:(id)sender
{
    ReportProblem* r = [[[ReportProblem alloc] initWithParent:self station:[self selectedStation]] autorelease];
    [r show];
}

- (IBAction)toggleFavorite:(id)sender
{
    if (![self selectedStation]) return;
    
    [[self selectedStation] setFavorite:![self selectedStation].favorite];
    [self renderFavoriteButton];

    NSString* key = @"didDisplayFavoritesTip";
    BOOL didDisplayFavoritesTip = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (!didDisplayFavoritesTip) {
        UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", nil) message:NSLocalizedString(@"FAVORITES_TIP", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alertView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - List

- (void)openList:(id)sender
{
    [_delegate mapViewControllerDidSelectList:self];
}

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search: %@", searchBar.text);
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - MKMapView

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Station"];
    if (!view) {
        view = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
        view.centerOffset = CGPointMake(12.0, -18.0);
    }

    // use default view for user location
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    StationAnnotation* a = (StationAnnotation*)annotation;
    UIImage* image = a.station.markerImage;
    view.image = image;
    return view;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    StationAnnotation* a = (StationAnnotation*) view.annotation;
    UIImage* image = a.station.markerImage;
    view.image = image;
    [self hideDetailsPaneAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    StationAnnotation* a = (StationAnnotation*) view.annotation;
    UIImage* image = [UIImage imageNamed:@"SelectedMarker.png"];
    view.image = image;
    [self showDetailsPane];
    [_map setCenterCoordinate:a.coordinate animated:YES];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    _myLocationButton.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _myLocationButton.hidden = NO;
}

@end

#pragma mark - 

@implementation MapViewController (Private)

- (void)hideDetailsPaneAnimated:(BOOL)animated
{
    if (animated) [UIView beginAnimations:nil context:nil];
    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, _map.frame.origin.y - _detailsPane.frame.size.height, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
    _detailsPane.hidden = NO;
    if (animated) [UIView commitAnimations];
}

- (UIImage*)imageForState:(AmountState)state
{
    switch (state) {
        case Red:
            return [UIImage imageNamed:@"redbox.png"];
            
        case Yellow:
            return [UIImage imageNamed:@"yellowbox.png"];

        case Green:
        default:
            return [UIImage imageNamed:@"greenbox.png"];
    }
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
    CLLocationDistance distance = [[self selectedStation] distanceFromLocation:currentLocation];
    _stationDistanceLabel.text = [Utils formattedDistance:distance];
}

- (void)populateDetails
{
    Station* station = [self selectedStation];
    if (!station) return;
    
    BOOL showBoxes = station.isActive && station.isOnline;
    
    _stationBoxesPanel.hidden = !showBoxes;
    _inactiveStationLabel.hidden = showBoxes;
    _inactiveStationLabel.text = station.statusText;
    
    _stationName.text = station.stationName;
    _availBikeLabel.text = [NSString stringWithFormat:@"%d", [station availBike]];
    _availParkLabel.text = [NSString stringWithFormat:@"%d", [station availSpace]];
    
    [self showDistanceForStation];
    
    // set the color of the boxes based on the amount of avail bike/park
    _parkBox.image = [self imageForState:station.parkState];
    _bikeBox.image = [self imageForState:station.bikeState];

    [self renderFavoriteButton];
}

- (Station*)selectedStation
{
    StationAnnotation* ann = (StationAnnotation*) [[_map selectedAnnotations] objectAtIndex:0];
    if (!ann) return nil;
    
    return ann.station;
}

- (void)showDetailsPane
{
    [self hideDetailsPaneAnimated:NO];
    if (![self selectedStation]) return;
    
    [self populateDetails];
    [UIView beginAnimations:nil context:nil];
    _detailsPane.frame = CGRectMake(_detailsPane.frame.origin.x, _map.frame.origin.y - 5.0, _detailsPane.frame.size.width, _detailsPane.frame.size.height);
    [UIView commitAnimations];
}

- (StationAnnotation*)annotationForStation:(Station*)s
{
    StationAnnotation* ann = [_annotations objectForKey:s.sid];
    if (!ann) {
        ann = [[[StationAnnotation alloc] initWithStation:s] autorelease];
        [_annotations setObject:ann forKey:s.sid];
        [_map addAnnotation:ann];
    }
    return ann;
}

- (void)reloadStations
{
    // load stations
    NSArray* stations = [StationList instance].stations;
    
    for (Station* station in stations)
    {
        if ([station isMyLocation]) continue; // do not display the 'my location' station.
                
        // make sure we have an annotation for this station.
        [self annotationForStation:station];
    }
    
    [self populateDetails];
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

- (void)renderFavoriteButton
{
    if (![self selectedStation]) return;
    _favoriteButton.selected = [self selectedStation].favorite;
}

@end

@implementation StationAnnotation

@synthesize station;

- (id)initWithStation:(Station*)s;
{
    self = [super init];
    if (self) {
        station = [s retain];
    }
    return self;
}

- (void)dealloc
{
    [station release];
    [super dealloc];
}

- (CLLocationCoordinate2D)coordinate
{
    return [station coords];
}

@end
