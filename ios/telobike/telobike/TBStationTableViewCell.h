//
//  TBStationTableViewCell.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBStation.h"

#define STATION_CELL_REUSE_IDENTIFIER @"STATION_CELL"

@interface TBStationTableViewCell : UITableViewCell

@property (strong, nonatomic) TBStation* station;

@end
