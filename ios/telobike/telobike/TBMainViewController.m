//
//  TBSearchViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/9/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

@import MapKit;

#import <SVGeocoder.h>
#import <InAppSettings.h>

#import "TBMainViewController.h"
#import "TBNavigationController.h"
#import "TBServer.h"
#import "UIColor+Style.h"
#import "TBAppDelegate.h"

@interface TBMainViewController () <UITabBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate>

// view controllers
@property (strong, nonatomic) TBListViewController* nearByViewController;
@property (strong, nonatomic) TBListViewController* favoritesViewController;
@property (strong, nonatomic) TBMapViewController* mapViewController;

// tabbar
@property (strong, nonatomic) IBOutlet UITabBar* tabBar;

// global actions
@property (strong, nonatomic) UIBarButtonItem* sideMenuBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem* searchBarButtonItem;

// search
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) MKDistanceFormatter* distanceFormatter;

@end

@implementation TBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // tabbar
    self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    self.tabBar.itemSpacing = 0.3f;

    self.nearByViewController = [self.navigation.viewControllers objectAtIndex:0];
    self.favoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favorites"];
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    
    // create tabbar items with proper selected images
    self.nearByViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Near Me", nil) image:[UIImage imageNamed:@"TabBar-NearMe"] selectedImage:[UIImage imageNamed:@"TabBar-NearMe-Highlighted"]];
    self.mapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Map", nil) image:[UIImage imageNamed:@"TabBar-Map"] selectedImage:[UIImage imageNamed:@"TabBar-Map-Highlighted"]];
    self.favoritesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Favorites", nil) image:[UIImage imageNamed:@"TabBar-Favorites"] selectedImage:[UIImage imageNamed:@"TabBar-Favorites-Highlighted"]];
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    [items addObject:self.nearByViewController.tabBarItem];
    [items addObject:self.favoritesViewController.tabBarItem];
    [items addObject:self.mapViewController.tabBarItem];
    
    self.tabBar.items = items;
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    self.tabBar.barTintColor = [UIColor tabbarBackgroundColor];
    self.tabBar.tintColor    = [UIColor tabbarTintColor];
    
    // global actions
    self.navigation.delegate = self;
//    self.sideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSideMenu:)];
    self.sideMenuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings:)];
    self.searchBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    
    // search
    self.searchDisplayController.searchBar.alpha = 0.0f;
    self.searchDisplayController.searchBar.tintColor = [UIColor tintColor];

    self.locationManager = [[CLLocationManager alloc] init];
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
    
    viewController.navigationItem.rightBarButtonItems = @[ self.sideMenuBarButtonItem, self.searchBarButtonItem ];
    self.tabBar.selectedItem = viewController.tabBarItem;
}

#pragma mark - Global actions

- (void)showSearch:(id)sender {
    [self.searchDisplayController setActive:YES animated:YES];
}

- (void)showSettings:(id)sender {
    InAppSettingsModalViewController* vc = [[InAppSettingsModalViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Tab Bar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == self.mapViewController.tabBarItem) {
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
    self.mapViewController.selectedPlacemark = nil;
    self.mapViewController.selectedStation = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // this means the change in the search bar was coming from the change in selection
    if (self.mapViewController.selectedStation) {
        return NO;
    }
    
    // do not search in case we have a placemark annotation selected
    if (self.mapViewController.selectedPlacemark) {
        return NO;
    }
    
    if (searchString.length == 0) {
        self.searchResults = nil;
        return YES;
    }
    
    TBServer* server = [TBServer instance];
    TBCity* city = server.city;
    
    [self geocodeSearch:searchString completion:^(NSArray *placemarks) {
        
        // filter results only from the city
        NSArray* placemarkResults = [placemarks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            SVPlacemark* placemark = evaluatedObject;
            
            if (![city.region containsCoordinate:placemark.coordinate]) {
                return NO;
            }
            
            // also check that the city name appears in the formatted address
            if ([placemark.formattedAddress rangeOfString:city.cityName options:NSCaseInsensitiveSearch].length == 0) {
                return NO;
            }
            
            return YES;
        }]];
        
        // now also search stations
        NSArray* stationsResults = [server.stations filteredStationsArrayWithQuery:searchString];
        
        // combine results
        NSArray* results = [placemarkResults arrayByAddingObjectsFromArray:stationsResults];
        
        CLLocation* referenceLocation = self.locationManager.location;
        if (!referenceLocation) {
            referenceLocation = [[CLLocation alloc] initWithLatitude:0.0f longitude:50.0];
        }
        
        self.searchResults = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CLLocation* location1 = [self locationFromSearchResult:obj1];
            CLLocation* location2 = [self locationFromSearchResult:obj2];
            CLLocationDistance distance1 = [referenceLocation distanceFromLocation:location1];
            CLLocationDistance distance2 = [referenceLocation distanceFromLocation:location2];
            return distance1 - distance2;
        }];
        
        [controller.searchResultsTableView reloadData];
    }];
    
    return NO;
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
    CLLocation* currentLocation = self.locationManager.location;
    
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"searchResult"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchResult"];
    }
    
    cell.textLabel.text = title;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.imageView.image = image;
    if (distance != -1.0f) {
        cell.detailTextLabel.text = [self.distanceFormatter stringFromDistance:distance];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // move to map view
    [self tabBar:self.tabBar didSelectItem:self.mapViewController.tabBarItem];
    [self.searchDisplayController setActive:NO animated:NO];
    
    id result = self.searchResults[indexPath.row];
    
    if ([result isKindOfClass:[SVPlacemark class]]) {
        SVPlacemark* placemark = result;
        self.mapViewController.selectedPlacemark = [[TBPlacemarkAnnotation alloc] initWithPlacemark:placemark];
        return;
    }
    
    if ([result isKindOfClass:[TBStation class]]) {
        TBStation* station = result;
        self.mapViewController.selectedStation = station;
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