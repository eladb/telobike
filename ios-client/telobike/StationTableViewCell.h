//
//  StationTableViewCell.h
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StationTableViewCell : UITableViewCell {
    NSDictionary* station;
}

@property (nonatomic, retain) IBOutlet UILabel* stationNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* distanceLabel;
@property (nonatomic, retain) IBOutlet UILabel* availBikeLabel;
@property (nonatomic, retain) IBOutlet UILabel* availSpaceLabel;
@property (nonatomic, retain) IBOutlet UIImageView* icon;

@property (nonatomic, retain) NSDictionary* station;

+ (StationTableViewCell*)cell;

@end
