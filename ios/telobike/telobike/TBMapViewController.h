//
//  TBSecondViewController.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBStation.h"

@interface TBMapViewController : UIViewController

@property (strong, nonatomic) TBStation* selectedStation;

@end