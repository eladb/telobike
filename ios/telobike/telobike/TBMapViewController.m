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
#import "KMLParser.h"
#import "TBStationAnnotationView.h"
#import "TBAvailabilityView.h"
#import "TBFavorites.h"
#import "TBGoogleMapsRouting.h"
#import "TBFeedbackMailComposeViewController.h"
#import "UIViewController+GAI.h"
#import "TBPlacemarkAnnotation.h"

@interface TBMapViewController () <MKMapViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UIToolbar* bottomToolbar;
@property (strong, nonatomic) UIBarButtonItem* backButtonItem;

// station details
@property (strong, nonatomic) IBOutlet UIView* stationDetails;
@property (strong, nonatomic) IBOutlet TBAvailabilityView* stationAvailabilityView;
@property (strong, nonatomic) IBOutlet UILabel* availabilityLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* toggleStationFavoriteButton;
@property (strong, nonatomic) IBOutlet UIView* labelBackgroundView;
@property (strong, nonatomic) IBOutlet UIView* topFillerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* drawerTopConstraint;

@property (strong, nonatomic) TBServer* server;

// routes
@property (assign, nonatomic) BOOL routesVisible;
@property (strong, nonatomic) KMLParser* kmlParser;

@property (assign, nonatomic) BOOL regionChangingForSelection;

@end

@implementation TBMapViewController

#pragma mark - View controller events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backButtonItem = self.navigationItem.leftBarButtonItem;
    
    self.server = [TBServer instance];
    
    [self observeValueOfKeyPath:@"stations" object:self.server with:^(id new, id old) {
        [self reloadAnnotations];
    }];
    
    [self observeValueOfKeyPath:@"city" object:self.server with:^(id new, id old) {
        MKCoordinateRegion region;
        region.center = self.server.city.cityCenter.coordinate;
        region.span = MKCoordinateSpanMake(0.05, 0.05);
        [self.mapView setRegion:region animated:NO];
    }];
    
    // map view
    MKUserTrackingBarButtonItem* trackingBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.bottomToolbar setItems:[self.bottomToolbar.items arrayByAddingObject:trackingBarButtonItem]];
    self.mapView.showsUserLocation = YES;
    
    self.stationAvailabilityView.alignCenter = YES;
    
    [self closeDetailsAnimated:NO];
}

- (void)openDetailsAnimated:(BOOL)animated {
    self.drawerTopConstraint.constant = 0.0f;
    self.topFillerView.hidden = YES;
    
    if (animated) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:8.0f
                            options:0
                         animations:^{ [self.view layoutIfNeeded]; }
                         completion:nil];
    }
}

- (void)closeDetailsAnimated:(BOOL)animated {
    self.drawerTopConstraint.constant = -self.stationDetails.frame.size.height;
    self.topFillerView.hidden = NO;

    if (animated) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:-8.0f
                            options:0
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[TBServer instance] reloadStations:nil];
    
    [self showOrHideRoutesOnMap];
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = self.backButtonItem;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self analyticsScreenDidAppear:@"map"];
}

#pragma mark - Navigation

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Annotations

- (void)showPlacemark:(SVPlacemark*)placemark {
    // delete any existing placemark annotations
    [self.mapView removeAnnotations:[self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[TBPlacemarkAnnotation class]];
    }]]];
    
    TBPlacemarkAnnotation* newAnnotation = [[TBPlacemarkAnnotation alloc] initWithPlacemark:placemark];
    [self.mapView addAnnotation:newAnnotation];
    [self.mapView selectAnnotation:newAnnotation animated:YES];
}

- (void)deselectAllAnnoations {
    for (id ann in self.mapView.annotations) {
        [self.mapView deselectAnnotation:ann animated:YES];
    }
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated {
    [self.mapView selectAnnotation:annotation animated:animated];
}

- (NSArray *)annoations {
    return self.mapView.annotations;
}

- (void)reloadAnnotations {
    // add stations that are not already defined as annoations
    NSMutableSet* newAnnotations = [NSMutableSet setWithArray:[TBServer instance].stations];
    [newAnnotations minusSet:[NSSet setWithArray:self.mapView.annotations]];
    [self.mapView addAnnotations:newAnnotations.allObjects];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* stationID = @"station";
    static NSString* placemarkID = @"placemark";
    
    if ([annotation isKindOfClass:[TBPlacemarkAnnotation class]]) {
        MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:placemarkID];
        if (!view) {
            MKPinAnnotationView* v = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkID];
            view = v;
            v.pinColor = MKPinAnnotationColorRed;
            v.animatesDrop = YES;
            v.canShowCallout = YES;
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

- (void)updateTitle:(NSString*)title {
    self.navigationItem.title = title ? title : self.title;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self closeDetailsAnimated:YES];
    [self updateTitle:nil];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSString* annotationTitle;
    MKCoordinateRegion annotationRegion;

    if ([view.annotation isKindOfClass:[TBStation class]]) {
        TBStation* selectedStation = (TBStation*)view.annotation;

        [self openDetailsAnimated:YES];
        
        MKCoordinateRegion region;
        region.span = MKCoordinateSpanMake(0.004, 0.004);
        region.center = selectedStation.coordinate;
        
        annotationRegion = region;
        annotationTitle = selectedStation.stationName;
        
        [self updateStationDetails];
    }
    
    if ([view.annotation isKindOfClass:[TBPlacemarkAnnotation class]]) {
        TBPlacemarkAnnotation* annoation = view.annotation;
        annotationTitle = annoation.placemark.formattedAddress;;
        annotationRegion = MKCoordinateRegionMakeWithDistance(annoation.coordinate, 1000.0f, 1000.0f);;
    }
    
    [self updateTitle:annotationTitle];
    self.regionChangingForSelection = YES;
    [self.mapView setRegion:annotationRegion animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (self.regionChangingForSelection) {
        return; // if region is changing for selection, do nothing
    }

    [self deselectAllAnnoations];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.regionChangingForSelection = NO;
}

#pragma mark - Station details

- (TBStation*)openedStation {
    TBStation* selectedStation = self.mapView.selectedAnnotations[0];
    if (![selectedStation isKindOfClass:[TBStation class]]) {
        NSLog(@"WARNING: selected annotation is not a station");
        return nil;
    }

    return  selectedStation;
}

- (void)updateStationDetails {
    TBStation* station = self.openedStation;
    if (!station) {
        return;
    }
    
    self.stationAvailabilityView.station = station;
    
    NSString* labelText = nil;
    switch (station.state) {
        case StationFull:
            labelText = NSLocalizedString(@"No parking", nil);
            break;
            
        case StationEmpty:
            labelText = NSLocalizedString(@"No bicycles", nil);
            break;
            
        case StationMarginal:
            labelText = NSLocalizedString(@"Almost empty", nil);
            break;
            
        case StationMarginalFull:
            labelText = NSLocalizedString(@"Almost full", nil);
            break;
            
        case StationInactive:
            labelText = NSLocalizedString(@"Not operational", nil);
            break;
            
        case StationUnknown:
        case StationOK:
        default:
            break;
    }
    
    self.availabilityLabel.hidden = !labelText;
    self.availabilityLabel.text = labelText;
    self.availabilityLabel.textColor = station.indicatorColor;
    self.labelBackgroundView.hidden = self.availabilityLabel.hidden;
    
    // set favorite
    UIImage* favoriteButtonImage = station.isFavorite ?
        [UIImage imageNamed:@"station-favorite-selected"] :
        [UIImage imageNamed:@"station-favorite-unselected"];
    
    [self.toggleStationFavoriteButton setImage:favoriteButtonImage];
}

- (IBAction)toggleStationFavorite:(id)sender {
    [self.openedStation setFavorite:!self.openedStation.isFavorite];
    [self updateStationDetails];
}

- (IBAction)sendStationReport:(id)sender {
    TBFeedbackMailComposeViewController* vc = [[TBFeedbackMailComposeViewController alloc] initWithFeedbackOption:TBFeedbackActionSheetService];
    NSString* subject = [NSString stringWithFormat:NSLocalizedString(@"Problem in station %@", nil), self.openedStation.sid];
    vc.mailComposeDelegate = self;
    [vc setSubject:subject];
    
    NSString* body = [NSString stringWithFormat:NSLocalizedString(@"Please describe the problem:\n\n\n=====================\nStation ID: %@\nName: %@\nAddress: %@", nil),
                      self.openedStation.sid,
                      self.openedStation.stationName,
                      self.openedStation.address ? self.openedStation.address : NSLocalizedString(@"N/A", nil)];
    
    [vc setMessageBody:body isHTML:NO];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)navigateToStation:(id)sender {
    NSString* dest = [NSString stringWithFormat:@"%g,%g", self.openedStation.coordinate.latitude, self.openedStation.coordinate.longitude];
    if (![TBGoogleMapsRouting routeFromAddress:@"" toAddress:dest]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Google Maps is not installed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

#pragma mark - My location

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"ERROR: unable to determine location: %@", error);
}

#pragma mark - Routes

- (void)showOrHideRoutesOnMap {
    BOOL showRoutes = [[NSUserDefaults standardUserDefaults] boolForKey:@"show_bicycle_routes"];
    
    if (showRoutes && !self.routesVisible) {
        if (!self.kmlParser) {
            NSURL* url = [[NSBundle mainBundle] URLForResource:@"routes" withExtension:@"kml"];
            self.kmlParser = [[KMLParser alloc] initWithURL:url];
            [self.kmlParser parseKML];
        }
        
        [self.mapView addOverlays:self.kmlParser.overlays];
        self.routesVisible = YES;
        return;
    }
    
    if (!showRoutes && self.routesVisible) {
        [self.mapView removeOverlays:self.kmlParser.overlays];
        self.routesVisible = NO;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [self.kmlParser rendererForOverlay:overlay];
}

//#pragma mark - Placemark search result
//
//- (void)setSelectedPlacemark:(TBPlacemarkAnnotation *)selectedPlacemark {
//
//    if (selectedPlacemark) {
//        [self deselectAllAnnoations];
//        self.selectedStation = nil;
//
//        // only remove previous placemark if there is a new one to select
//        // otherwise, we just want to deselect it.
//        [self.mapView removeAnnotation:_selectedPlacemark];
//        [self.mapView addAnnotation:selectedPlacemark];
//    }
//    
//    _selectedPlacemark = selectedPlacemark;
//    [self.mapView selectAnnotation:selectedPlacemark animated:YES];
//}

@end
