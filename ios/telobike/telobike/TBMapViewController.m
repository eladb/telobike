//
//  TBSecondViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

@import MapKit;
@import QuartzCore;

#import <SVGeocoder/SVGeocoder.h>

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
#import "TBPlacemarkAnnotation.h"

@interface TBMapViewController () <MKMapViewDelegate, TBStationDetailsViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UIView*    stationDetailsContainerView;
@property (strong, nonatomic) IBOutlet UIToolbar* bottomToolbar;

@property (strong, nonatomic) TBServer* server;
@property (strong, nonatomic) NSMutableDictionary*  markers;
@property (strong, nonatomic) TBStationDetailsView* stationDetails;
@property (strong, nonatomic) KMLParser* kmlParser;

@property (assign, nonatomic) BOOL regionChangingForSelection;

// search
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) TBPlacemarkAnnotation* placemarkAnnotation;

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
    
    
    // station details
    self.stationDetails = [[NSBundle mainBundle] loadViewFromNibForClass:[TBStationDetailsView class]];
    self.stationDetails.stationDetailsDelegate = self;
    self.stationDetailsContainerView.backgroundColor = [UIColor detailsBackgroundColor];
    [self.stationDetailsContainerView addSubview:self.stationDetails];
    
    [self loadRoutesFromKML];
  
    MKUserTrackingBarButtonItem* trackingBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.bottomToolbar setItems:[self.bottomToolbar.items arrayByAddingObject:trackingBarButtonItem]];


    self.navigationItem.title = self.title;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.searchDisplayController.navigationItem.rightBarButtonItem = [self.navigation sideMenuBarButtonItem];
    self.searchDisplayController.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
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
    self.navigation.tabBar.selectedItem = self.navigation.mapViewController.tabBarItem;
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
    static NSString* stationID = @"station";
    static NSString* placemarkID = @"placemark";
    
    if ([annotation isKindOfClass:[TBPlacemarkAnnotation class]]) {
        MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:placemarkID];
        if (!view) {
            MKPinAnnotationView* v = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkID];
            view = v;
            v.pinColor = MKPinAnnotationColorPurple;
            v.animatesDrop = YES;
        }
        view.annotation = annotation;
        return view;
    }
    
    // only if this is a station annotation
    if ([annotation isKindOfClass:[TBStation class]]) {
        MKAnnotationView* view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:stationID];
        if (!view) {
            view = [[TBStationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stationID];
        }
        view.annotation = annotation;
        return view;
    }
    
    return nil;
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
    self.searchDisplayController.searchBar.text = nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[TBStation class]]) {
        _selectedStation = (TBStation*)view.annotation;

        self.stationDetails.station = (TBStation*)view.annotation;
        [self showStationDetailsAnimated:YES];
        
        MKCoordinateRegion region;
        region.span = MKCoordinateSpanMake(0.004, 0.004);
        region.center = self.selectedStation.coordinate;
        
        self.regionChangingForSelection = YES;
        [self.mapView setRegion:region animated:YES];

        self.searchDisplayController.searchBar.text = self.selectedStation.stationName;
        return;
    }
    
    if ([view.annotation isKindOfClass:[TBPlacemarkAnnotation class]]) {
        TBPlacemarkAnnotation* annoation = view.annotation;
        self.searchDisplayController.searchBar.text = annoation.placemark.formattedAddress;
        return;
    }
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

#pragma mark - Search

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.navigation.tabBar.alpha = 0.0f;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.navigation.tabBar.alpha = 1.0f;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.mapView removeAnnotation:self.placemarkAnnotation];
    self.placemarkAnnotation = nil;
    self.selectedStation = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // this means the change in the search bar was coming from the change in selection
    if (self.selectedStation) {
        return NO;
    }
    
    // do not search in case we have a placemark annotation selected
    if (self.placemarkAnnotation) {
        return NO;
    }
    
    [self search:searchString];
    return NO;
}

- (void)search:(NSString*)query {
    if (query.length == 0) {
        self.searchResults = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    TBServer* server = [TBServer instance];
    TBCity* city = server.city;
    
    [SVGeocoder geocode:query region:city.region completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        // filter results only from the city
        NSArray* placemarkResults = [placemarks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            SVPlacemark* placemark = evaluatedObject;
            
            if (![city.region containsCoordinate:placemark.coordinate]) {
                return NO;
            }
            
            // also check that the city name appears in the formatted address
            if ([placemark.formattedAddress rangeOfString:city.cityName options:NSCaseInsensitiveSearch].length == 0) {
                return NO;
            }
            
            return YES;
        }]];
        
        // now also search stations
        NSArray* stationsResults = [server.stations filteredStationsArrayWithQuery:query];
        
        NSArray* results = [placemarkResults arrayByAddingObjectsFromArray:stationsResults];

        CLLocation* referenceLocation = self.mapView.userLocation.location;
        if (!referenceLocation) {
            referenceLocation = [[CLLocation alloc] initWithLatitude:0.0f longitude:50.0];
        }

        self.searchResults = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CLLocation* location1 = [self locationFromSearchResult:obj1];
            CLLocation* location2 = [self locationFromSearchResult:obj2];
            CLLocationDistance distance1 = [referenceLocation distanceFromLocation:location1];
            CLLocationDistance distance2 = [referenceLocation distanceFromLocation:location2];
            return distance1 - distance2;
        }];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (CLLocation*)locationFromSearchResult:(id)result {
    if ([result isKindOfClass:[TBStation class]]) {
        return ((TBStation*)result).location;
    }
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        return ((SVPlacemark*)result).location;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id result = self.searchResults[indexPath.row];
    
    NSString* title;
    UIImage* image;
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        SVPlacemark* placemark = result;
        title = placemark.formattedAddress;
        image = [UIImage imageNamed:@"Placemark"];
    }
    else if ([result isKindOfClass:[TBStation class]]) {
        TBStation* station = result;
        title = station.stationName;
        image = station.markerImage;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"searchResult"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResult"];
    }
    
    cell.textLabel.text = title;
    cell.imageView.image = image;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController.searchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO animated:YES];
    
    id result = self.searchResults[indexPath.row];
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        SVPlacemark* placemark = result;
        
        if (self.placemarkAnnotation) {
            [self.mapView removeAnnotation:self.placemarkAnnotation];
        }
        
        self.placemarkAnnotation = [[TBPlacemarkAnnotation alloc] initWithPlacemark:placemark];
        [self.mapView addAnnotation:self.placemarkAnnotation];
        
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 1000.0f, 1000.0f);
        [self.mapView setRegion:r animated:YES];
        
        self.searchDisplayController.searchBar.text = placemark.formattedAddress;
        return;
    }
    
    if ([result isKindOfClass:[TBStation class]]) {
        TBStation* station = result;
        self.selectedStation = station;
        return;
    }
}

@end
