//
//  RootViewController.h
//  telofun
//
//  Created by eladb on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EGORefreshTableHeaderView.h"
#import "Station.h"

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
    NSDate* lastRefresh;

    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL _isLoading;
    
    CGFloat _myLocationCellHeight;
    CGFloat _stationCellHeight;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl* filters;
@property (nonatomic, retain) IBOutlet UIView* noFavorites;
@property (nonatomic, retain) IBOutlet UILabel* noFavorites1;
@property (nonatomic, retain) IBOutlet UILabel* noFavorites2;
@property (nonatomic, assign) id<RootViewControllerDelegate> delegate;

- (void)about:(id)sender;
- (void)showSearchBarAnimated:(BOOL)animated;
- (void)hideSearchBarAnimated:(BOOL)animated;
- (IBAction)filterFavoritesChanged:(id)sender;


@end

@protocol RootViewControllerDelegate <NSObject>

@required

- (void)rootViewController:(RootViewController*)viewController didSelectStation:(Station*)station;
- (void)rootViewControllerWillAppear:(RootViewController*)viewController;
- (void)rootViewControllerDidTouchFeedback:(RootViewController*)viewController;

@end