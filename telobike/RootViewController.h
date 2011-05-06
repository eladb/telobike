//
//  RootViewController.h
//  telofun
//
//  Created by eladb on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    CLLocationManager* locationManager;
    NSArray* stations;
    NSString* filter;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)refreshStations:(id)sender;

@end
