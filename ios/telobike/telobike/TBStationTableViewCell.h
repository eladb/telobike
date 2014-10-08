//
//  TBStationTableViewCell.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STATION_CELL_REUSE_IDENTIFIER @"STATION_CELL"

@class TBStation;

@interface TBStationTableViewCell : UITableViewCell

@property (strong, nonatomic) TBStation* station;

@end
