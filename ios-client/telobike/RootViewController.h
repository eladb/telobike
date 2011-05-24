//
//  RootViewController.h
//  telofun
//
//  Created by eladb on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapViewController.h"

@interface RootViewController : UIViewController 
    <CLLocationManagerDelegate, 
     UITableViewDelegate, 
     UITableViewDataSource, 
     UISearchBarDelegate, 
     UIAlertViewDelegate, 
     MFMailComposeViewControllerDelegate,
     UINavigationControllerDelegate,
     UIScrollViewDelegate>
{
    CLLocationManager* locationManager;
    NSArray* stations;
    NSString* filter;
    MapViewController* mapView;
    NSDate* lastRefresh;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;

@end
