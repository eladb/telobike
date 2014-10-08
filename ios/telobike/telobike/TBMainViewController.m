//
//  TBSearchViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/9/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

@import MapKit;

#import <SVGeocoder.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>

#import "TBMainViewController.h"
#import "TBNavigationController.h"
#import "TBTimerViewController.h"
#import "TBServer.h"
#import "UIColor+Style.h"
#import "TBAppDelegate.h"
#import "TBSearchResultTableViewCell.h"

@interface TBMainViewController () <UITabBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate>

// view controllers
@property (strong, nonatomic) TBListViewController* nearByViewController;
@property (strong, nonatomic) TBListViewController* favoritesViewController;
@property (strong, nonatomic) TBMapViewController* mapViewController;
@property (strong, nonatomic) TBTimerViewController* timerViewController;
@property (strong, nonatomic) IASKAppSettingsViewController* settingsViewController;

// tabbar
@property (strong, nonatomic) IBOutlet UITabBar* tabBar;

// search
@property (strong, nonatomic) UIBarButtonItem* searchBarButtonItem;
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) MKDistanceFormatter* distanceFormatter;

@end

@implementation TBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nearByViewController = [self.navigation.viewControllers objectAtIndex:0];
    self.favoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favorites"];
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    self.timerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"timer"];
    self.settingsViewController = [[IASKAppSettingsViewController alloc] init];
    self.settingsViewController.showCreditsFooter = NO;
    
    // load nibs
    [self.mapViewController view];
    [self.nearByViewController view];
    
    // create tabbar items with proper selected images
    self.nearByViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Near Me", nil) image:[UIImage imageNamed:@"TabBar-NearMe"] selectedImage:[UIImage imageNamed:@"TabBar-NearMe-Highlighted"]];
    self.mapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Map", nil) image:[UIImage imageNamed:@"TabBar-Map"] selectedImage:[UIImage imageNamed:@"TabBar-Map-Highlighted"]];
    self.favoritesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Favorites", nil) image:[UIImage imageNamed:@"TabBar-Favorites"] selectedImage:[UIImage imageNamed:@"TabBar-Favorites-Highlighted"]];
    self.timerViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Timer", nil) image:[UIImage imageNamed:@"TabBar-Timer"] selectedImage:[UIImage imageNamed:@"TabBar-Timer-Highlighted"]];
    self.settingsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"TabBar-Gear"] selectedImage:[UIImage imageNamed:@"TabBar-Gear-Highlighted"]];
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    [items addObject:self.nearByViewController.tabBarItem];
    [items addObject:self.favoritesViewController.tabBarItem];
    [items addObject:self.mapViewController.tabBarItem];
    [items addObject:self.timerViewController.tabBarItem];
    [items addObject:self.settingsViewController.tabBarItem];
    
    self.tabBar.items = items;
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    self.tabBar.barTintColor = [UIColor tabbarBackgroundColor];
    self.tabBar.tintColor    = [UIColor tabbarTintColor];
    
    // global actions
    self.navigation.delegate = self;
    self.searchBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    
    // search
    self.searchDisplayController.searchBar.alpha = 0.0f;
    self.searchDisplayController.searchBar.tintColor = [UIColor tintColor];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([TBSearchResultTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"TBSearchResultTableViewCell"];

    self.distanceFormatter = [[MKDistanceFormatter alloc] init];
    self.distanceFormatter.units = MKDistanceFormatterUnitsMetric;
    self.distanceFormatter.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (TBNavigationController*)navigation {
    UIViewController* child = self.childViewControllers[0];
    NSAssert(!child || [child isKindOfClass:[TBNavigationController class]], @"child must be TBNavigationViewController");
    return (TBNavigationController*)child;
}

#pragma mark - Navigation

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // fix insets for table view controllers
    if ([viewController isKindOfClass:[UITableViewController class]]) {
        UITableView* tableView = (UITableView*)viewController.view;
        UIEdgeInsets insets = tableView.contentInset;
        insets.bottom = self.tabBar.frame.size.height;
        tableView.contentInset = insets;
    }
    
    viewController.navigationItem.rightBarButtonItems = @[ /*self.sideMenuBarButtonItem, */self.searchBarButtonItem ];
    self.tabBar.selectedItem = viewController.tabBarItem;
}

#pragma mark - Global actions

- (void)showSearch:(id)sender {
    [self.searchDisplayController setActive:YES animated:YES];
}

#pragma mark - Tab Bar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == self.mapViewController.tabBarItem) {
        [self.mapViewController showMyLocation];

        // if the top view controller is already the map, don't do anything
        if (self.navigation.topViewController == self.mapViewController) {
            return;
        }
        self.navigation.viewControllers = @[ self.mapViewController ];
        
        return;
    }
    
    if (item == self.nearByViewController.tabBarItem) {
        self.navigation.viewControllers = @[ self.nearByViewController ];
        CGPoint offset = CGPointZero;
        offset.y = -self.nearByViewController.tableView.contentInset.top;
        [self.nearByViewController.tableView setContentOffset:offset animated:YES];
        return;
    }
    
    if (item == self.favoritesViewController.tabBarItem) {
        self.navigation.viewControllers = @[ self.favoritesViewController ];
        CGPoint offset = CGPointZero;
        offset.y = -self.favoritesViewController.tableView.contentInset.top;
        [self.favoritesViewController.tableView setContentOffset:offset animated:YES];
        return;
    }
    
    if (item == self.timerViewController.tabBarItem) {
        self.navigation.viewControllers = @ [ self.timerViewController ];
        return;
    }
    
    if (item == self.settingsViewController.tabBarItem) {
        self.navigation.viewControllers = @ [ self.settingsViewController ];
        return;
    }
}

#pragma mark - Search

- (void)search:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.searchDisplayController.searchBar.alpha = 1.0f;
    }];
    
    [self.searchDisplayController setActive:YES animated:YES];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [UIView animateWithDuration:0.25f animations:^{
        self.searchDisplayController.searchBar.alpha = 1.0f;
    }];
    
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [UIView animateWithDuration:0.25f animations:^{
        self.searchDisplayController.searchBar.alpha = 0.0f;
    }];
    
    [self.searchDisplayController.searchBar resignFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = 50.0f;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.mapViewController deselectAllAnnoations];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    if (searchString.length == 0) {
        self.searchResults = nil;
        return YES;
    }
    
    TBServer* server = [TBServer instance];
    TBCity* city = server.city;
    
    [self geocodeSearch:searchString completion:^(NSArray *placemarks) {
        
        // filter results only from the city
        NSArray* results = [placemarks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            SVPlacemark* placemark = evaluatedObject;
            
            if (![city.region containsCoordinate:placemark.coordinate]) {
                return NO;
            }
            
            return YES;
        }]];
        
        // add stations that are nearby any of the placemarks
        results = [results arrayByAddingObjectsFromArray:[self stationsNearPlacemarks:results]];
        
        // add stations with names matching the search query
        NSArray* stationsResults = [server.stations filteredStationsArrayWithQuery:searchString];
        results = [results arrayByAddingObjectsFromArray:stationsResults];
        
        // uniqify
        results = [[NSSet setWithArray:results] allObjects];

        // sort by distance
        self.searchResults = [[TBServer instance] sortStationsByDistance:results];
        [controller.searchResultsTableView reloadData];
    }];
    
    return NO;
}

- (NSArray*)stationsNearPlacemarks:(NSArray*)placemarks {
    NSArray* stations = [TBServer instance].stations;
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (SVPlacemark* placemark in placemarks) {
        // for close by stations (< 1km)
        for (TBStation* station in stations) {
            CLLocationDistance distance = [station.location distanceFromLocation:placemark.location];
            if (distance <= 500) {
                [result addObject:station];
            }
        }
    }

    return result;
}

- (void)geocodeSearch:(NSString*)query completion:(void(^)(NSArray* placemarks))completion {
    if (query.length < 3) {
        return completion(@[]); // search query too short
    }
    
    TBServer* server = [TBServer instance];
    TBCity* city = server.city;
    
    [SVGeocoder geocode:query region:city.region completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSLog(@"geocode error: %@", error);
        }
        
        return completion(placemarks);
    }];
}

- (CLLocation*)locationFromSearchResult:(id)result {
    if ([result isKindOfClass:[TBStation class]]) {
        return ((TBStation*)result).location;
    }
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        return ((SVPlacemark*)result).location;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id result = self.searchResults[indexPath.row];
    
    NSString* title;
    UIImage* image;
    CLLocationDistance distance = -1.0f;
    CLLocation* currentLocation = [TBServer instance].currentLocation;
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        SVPlacemark* placemark = result;
        title = placemark.formattedAddress;
        image = [UIImage imageNamed:@"Placemark"];
        
        if (currentLocation && placemark.location) {
            distance = [placemark.location distanceFromLocation:currentLocation];
        }
    }
    else if ([result isKindOfClass:[TBStation class]]) {
        TBStation* station = result;
        title = station.stationName;
        image = station.markerImage;
        
        if (currentLocation && station.location) {
            distance = [station.location distanceFromLocation:currentLocation];
        }
    }
    
    TBSearchResultTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TBSearchResultTableViewCell"];
    cell.title = title;
    cell.image = image;
    if (distance != -1.0f) {
        cell.detail = [self.distanceFormatter stringFromDistance:distance];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // move to map view
    [self tabBar:self.tabBar didSelectItem:self.mapViewController.tabBarItem];
    [self.searchDisplayController setActive:NO animated:NO];
    
    id result = self.searchResults[indexPath.row];
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        [self.mapViewController showPlacemark:result];
        return;
    }
    
    if ([result isKindOfClass:[TBStation class]]) {
        TBStation* station = result;
        [self.mapViewController selectAnnotation:station animated:YES];
        return;
    }
}

@end

@implementation UIViewController (TB)

- (TBMainViewController*)main {
    TBMainViewController* vc = (TBMainViewController*)self.parentViewController.parentViewController;
    NSAssert(!vc || [vc isKindOfClass:[TBMainViewController class]], @"invalid app anatomy");
    return vc;
}

@end