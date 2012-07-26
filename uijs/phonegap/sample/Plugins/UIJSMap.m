//
//  UIJSMap.m
//  sample
//
//  Created by ELAD BEN-ISRAEL on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIJSMap.h"

@interface NSDictionary (Location)

- (CLLocationCoordinate2D)locationForKey:(NSString*)key;

@end

@implementation NSDictionary (Location)

- (CLLocationCoordinate2D)locationForKey:(NSString *)key
{
    NSArray* location = [self objectForKey:key];
    CLLocationDegrees lat = [[location objectAtIndex:0] floatValue];
    CLLocationDegrees lng = [[location objectAtIndex:1] floatValue];
    return CLLocationCoordinate2DMake(lat, lng);
}

@end

@interface MarkerAnnotation : NSObject<MKAnnotation>

@property (nonatomic, retain) NSDictionary* data;
@property (nonatomic, readonly) NSString* image;
@property (nonatomic, readonly) NSString* rightCalloutImage;
@property (nonatomic, readonly) NSString* leftCalloutImage;

@property (nonatomic, readonly) BOOL hasCenter;
@property (nonatomic, readonly) CGPoint center;

@end

@implementation MarkerAnnotation

@synthesize data;

- (CLLocationCoordinate2D)coordinate
{
    return [data locationForKey:@"location"];
}

- (NSString *)title
{
    return [data objectForKey:@"title"];
}

- (NSString *)subtitle
{
    return [data objectForKey:@"subtitle"];
}

- (NSString*)image
{
    return [data objectForKey:@"image"];
}

- (NSString *)rightCalloutImage
{
    return [data objectForKey:@"rightCalloutImage"];
}

- (NSString*)leftCalloutImage
{
    NSString* left = [data objectForKey:@"leftCalloutImage"];
    if (!left) left = [data objectForKey:@"icon"];
    return left;
}

- (BOOL)hasCenter
{
    return [data objectForKey:@"center"] != nil;
}

- (CGPoint)center
{
    if (![self hasCenter]) return CGPointMake(0, 0);
    return CGPointMake([data locationForKey:@"center"].latitude, [data locationForKey:@"center"].longitude);
}

@end

@interface UIJSMap ()
{
    MKMapViewWithTouch* mapView;
}
@end

@implementation UIJSMap

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mapView = [[MKMapViewWithTouch alloc] initWithFrame:self.bounds];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mapView.delegate = self;
        mapView.touchDelegate = self;
        [self addSubview:mapView];
    }
    return self;
}

- (void)uijs_set_region:(NSDictionary*)region
{
    CLLocationCoordinate2D center = [region locationForKey:@"center"];
    CLLocationCoordinate2D distance = [region locationForKey:@"distance"];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(center, distance.latitude, distance.longitude) animated:YES];
}

- (void)uijs_set_markers:(NSArray*)markers
{
    NSLog(@"uijs_set_markers: %d markers", [markers count]);
    
    NSMutableArray* annotations = [NSMutableArray array];

    for (NSDictionary* marker in markers) {
        MarkerAnnotation* ann = [[MarkerAnnotation alloc] init];
        ann.data = marker;
        [annotations addObject:ann];
    }
    
    [mapView removeAnnotations:[mapView annotations]];
    [mapView addAnnotations:annotations];
}

- (void)uijs_set_user_location:(id)options
{
    BOOL visible = [[options objectForKey:@"visible"] boolValue];
    BOOL track = [[options objectForKey:@"track"] boolValue];
    BOOL heading = [[options objectForKey:@"heading"] boolValue];

    mapView.showsUserLocation = visible;
    NSLog(@"shows:%d", mapView.showsUserLocation);
    MKUserTrackingMode trackingMode = MKUserTrackingModeNone;
    if (visible && track && !heading) trackingMode = MKUserTrackingModeFollow;
    if (visible && track && heading) trackingMode = MKUserTrackingModeFollowWithHeading;
    [mapView setUserTrackingMode:trackingMode animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)a
{
    if ([a isKindOfClass:[MKUserLocation class]]) {
        return nil; // use default view for user location
    }

    MarkerAnnotation* annotation = (MarkerAnnotation*)a;
    MKAnnotationView* view;
    
    NSString* image = ((MarkerAnnotation*)annotation).image;
    
    if (!image) {
        view = (MKPinAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (!view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
            ((MKPinAnnotationView*)view).animatesDrop = YES;
        }
    }
    else {
        view = [mv dequeueReusableAnnotationViewWithIdentifier:@"marker"];
        if (!view) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"marker"];
        }
        
        view.image = [self.uijs imageForResource:image];
        
        if (annotation.hasCenter) {
            view.centerOffset = annotation.center;
            view.calloutOffset = CGPointMake(-annotation.center.x, view.calloutOffset.y);
        }
    }
    
//    view.canShowCallout = YES;
    view.annotation = annotation;
    
    NSString* rightCalloutImage = annotation.rightCalloutImage;
    if (rightCalloutImage) {
        view.rightCalloutAccessoryView = [[UIImageView alloc] initWithImage:[self.uijs imageForResource:rightCalloutImage]];
    }

    NSString* leftCalloutImage = annotation.leftCalloutImage;
    if (leftCalloutImage) {
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[self.uijs imageForResource:leftCalloutImage]];
    }
    
    return view;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self emitEvent:@"marker-selected" withObject:((MarkerAnnotation*)view.annotation).data];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self emitEvent:@"marker-deselected" withObject:((MarkerAnnotation*)view.annotation).data];
}

- (void)mapViewWillMove:(MKMapView *)mapView
{
    [self emitEvent:@"move" withObject:nil];
}

@end
