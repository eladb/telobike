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
#import "EGORefreshTableHeaderView.h"

@interface RootViewController : UIViewController 
    <CLLocationManagerDelegate, 
     UITableViewDelegate, 
     UITableViewDataSource, 
     UISearchBarDelegate, 
     UINavigationControllerDelegate,
     UIScrollViewDelegate,
     EGORefreshTableHeaderDelegate>
{
    CLLocationManager* locationManager;
    NSArray* stations;
    NSString* filter;
    MapViewController* mapView;
    NSDate* lastRefresh;

    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL _isLoading;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;

@end
