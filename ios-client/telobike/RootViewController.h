//
//  RootViewController.h
//  telofun
//
//  Created by eladb on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MapViewController.h"
#import "EGORefreshTableHeaderView.h"

@protocol RootViewControllerDelegate;

@interface RootViewController : UIViewController
    <UITableViewDelegate, 
     UITableViewDataSource, 
     UISearchBarDelegate, 
     UINavigationControllerDelegate,
     UIScrollViewDelegate,
     EGORefreshTableHeaderDelegate,
     MFMailComposeViewControllerDelegate>
{
    NSArray* stations;
    NSString* filter;
    MapViewController* mapView;
    NSDate* lastRefresh;

    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL _isLoading;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl* filters;
@property (nonatomic, assign) id<RootViewControllerDelegate> delegate;

- (void)about:(id)sender;
- (void)showSearchBarAnimated:(BOOL)animated;
- (void)hideSearchBarAnimated:(BOOL)animated;


+ (void)showAbout;

@end

@protocol RootViewControllerDelegate <NSObject>

@required

- (void)rootViewController:(RootViewController*)viewController didSelectStation:(Station*)station;

@end