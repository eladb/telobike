//
//  TBAvailabilityView.h
//  telobike
//
//  Created by Elad Ben-Israel on 10/3/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TBStation.h"

@class TBStation;

@interface TBAvailabilityView : UIView

@property (strong, nonatomic) TBStation* station;
@property (assign, nonatomic) BOOL alignCenter;

@end
