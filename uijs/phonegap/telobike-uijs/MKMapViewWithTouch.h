//
//  MKMapViewWithTouch.h
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol MKMapViewWithTouchDelegate;

@protocol GestureRecognizerProxy <NSObject>

@required
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface MKMapViewWithTouch : MKMapView <UIGestureRecognizerDelegate, GestureRecognizerProxy>

@property (nonatomic, assign) id<MKMapViewWithTouchDelegate> touchDelegate;

@end

@protocol MKMapViewWithTouchDelegate <NSObject>

- (void)mapViewWillMove:(MKMapView*)mapView;

@end