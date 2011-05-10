//
//  StationCalloutView.h
//  telofun
//
//  Created by eladb on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StationCalloutView : UIViewController {
    NSDictionary* _station;
}

@property (nonatomic, retain) NSDictionary* station;

@property (nonatomic, retain) IBOutlet UILabel* stationName;
@property (nonatomic, retain) IBOutlet UIImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* notActive;
@property (nonatomic, retain) IBOutlet UILabel* bikeAvail;
@property (nonatomic, retain) IBOutlet UILabel* spacesAvail;
@property (nonatomic, retain) IBOutlet UILabel* bikeAvailLabel;
@property (nonatomic, retain) IBOutlet UILabel* spacesAvailLabel;

@end
