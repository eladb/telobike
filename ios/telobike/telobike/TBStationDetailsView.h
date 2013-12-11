//
//  TBStationDetailsView.h
//  telobike
//
//  Created by Elad Ben-Israel on 10/2/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBStation.h"
#import "TBDrawerView.h"

@protocol TBStationDetailsViewDelegate;

@interface TBStationDetailsView : TBDrawerView

@property (assign, nonatomic) id<TBStationDetailsViewDelegate> stationDetailsDelegate;
@property (strong, nonatomic) TBStation* station;

@end

@protocol TBStationDetailsViewDelegate <NSObject>

- (void)stationDetailsActionClicked:(TBStationDetailsView*)detailsView;

@end