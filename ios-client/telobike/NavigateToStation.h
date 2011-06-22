//
//  NavigateToStation.h
//  telobike
//
//  Created by eladb on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Station.h"

@interface NavigateToStation : NSObject <UIActionSheetDelegate>

@property (nonatomic, retain) Station* station;
@property (nonatomic, retain) UIViewController* viewController;

- (void)show;

@end
