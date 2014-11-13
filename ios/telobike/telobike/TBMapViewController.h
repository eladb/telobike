//
//  TBSecondViewController.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVPlacemark.h"

@class TBStation;

@interface TBMapViewController : UIViewController

- (void)deselectAllAnnoations;
- (void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;
- (NSArray*)annoations;

- (void)showPlacemark:(SVPlacemark*)placemark;
- (void)showMyLocation;

@end
