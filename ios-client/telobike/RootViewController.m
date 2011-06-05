//
//  RootViewController.m
//  telofun
//
//  Created by eladb on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RootViewController.h"
#import "JSON.h"
#import "StationTableViewCell.h"
#import "AppDelegate.h"
#import "City.h"
#import "StationList.h"
#import "MapViewController.h"
#import "NSDictionary+Station.h"
#import "SendFeedback.h"
#import "IASKSettingsReader.h"

static const NSTimeInterval kMinimumAutorefreshInterval = 5 * 60; // 5 minutes

@interface RootViewController (Private)

- (void)sortStations;
- (BOOL)doesStation:(NSDictionary*)station containKeyword:(NSString*)keyword;
- (BOOL)filterStation:(NSDictionary*)station;

// navigation bar icon handlers
- (void)refreshStations:(id)sender;
- (void)about:(id)sender;

// keyboard events
- (void)keyboardDidShow:(NSNotification*)n;
- (void)keyboardWillHide:(NSNotification*)n;

- (void)hideSearchBarAnimated:(BOOL)animated;

- (void)settingsChanged:(NSNotification*)n;

@end

@implementation RootViewController

@synthesize tableView=_tableView;
@synthesize searchBar=_searchBar;

- (void)dealloc
{
    [_tableView release];
    [_searchBar release];
    [mapView release];
    [locationManager release];
    [stations release];
    [filter release];
    [lastRefresh release];
    [super dealloc];
}

- (void)viewDidLoad
{
    //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:kIASKAppSettingChanged object:nil];
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    [[City instance] refreshWithCompletion:^
     {
         self.navigationItem.title = [City instance].serviceName;
     }];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                            target:self action:@selector(refreshStations:)] autorelease];
    
    NSString* aboutTitle = NSLocalizedString(@"SEND_FEEDBACK_BUTTON", nil);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:aboutTitle style:UIBarButtonItemStylePlain 
                                                                             target:self action:@selector(about:)] autorelease];
    
    _tableView.rowHeight = [StationTableViewCell cell].frame.size.height;
    
    if (!mapView)
    {
        mapView = [MapViewController new];
    }
    
    // register for keyboard notifications so we can change the size of the list view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self hideSearchBarAnimated:NO];
    
    
    if (!_refreshHeaderView) 
    {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 
                                                                                         -_tableView.bounds.size.height, 
                                                                                         self.view.frame.size.width, 
                                                                                         _tableView.bounds.size.height)];
		_refreshHeaderView.delegate = self;
		[_tableView addSubview:_refreshHeaderView];
	}
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // if the last refresh was more than 5 minutes ago, refresh. otherwise, just just sort by distance.
    if (!lastRefresh || [[NSDate date] timeIntervalSinceDate:lastRefresh] > kMinimumAutorefreshInterval)
    {
        [self refreshStations:nil];
    }

    [self sortStations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stations count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    StationTableViewCell *cell = (StationTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [StationTableViewCell cell];
    }
    
    NSDictionary* station = [stations objectAtIndex:[indexPath row]];
    [cell setStation:station];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* station = [stations objectAtIndex:[indexPath row]];
    
    [mapView selectStation:station];
    [self.navigationController pushViewController:mapView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [filter release];
    filter = nil;
    
    if (searchText && searchText.length) filter = [searchText retain];
    [self sortStations];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self hideSearchBarAnimated:YES];
    searchBar.text = nil;
    [filter release];
    filter = nil;
    [self sortStations];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    // ugly hack to enable cancel button:
    // http://stackoverflow.com/questions/4348351/uisearchbar-disable-auto-disable-of-cancel-button
    for (UIView* possibleButton in searchBar.subviews)
    {
        if ([possibleButton isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self sortStations];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self searchBarSearchButtonClicked:_searchBar];
}

#pragma mark EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self refreshStations:nil];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return lastRefresh;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end

@implementation RootViewController (Private)

- (void)refreshStations:(id)sender
{
    _isLoading = YES;
    [[StationList instance] refreshStationsWithCompletion:^{
        [lastRefresh release];
        lastRefresh = [NSDate new];
        [self sortStations];
        _isLoading = NO;

        [_refreshHeaderView refreshLastUpdatedDate];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }];
}

NSInteger compareDistance(id stationObj1, id stationObj2, void* ctx)
{
    NSDictionary* station1 = stationObj1;
    NSDictionary* station2 = stationObj2;

    double dist1 = [[station1 objectForKey:@"distance"] doubleValue];
    double dist2 = [[station2 objectForKey:@"distance"] doubleValue];
    return dist1 - dist2;
}

- (void)sortStations
{
    NSArray* rawStations = [[StationList instance] stations];
    
    // calcaulte the distance of each station from our current location (if we have)
    CLLocation* currentLocation = locationManager.location;
    
    // if we have current location, add the distance of each station to the current
    // location and then it will be used for sorting.
    if (currentLocation)
    {
        for (NSDictionary* station in rawStations)
        {
            NSNumber* latitudeNumber = [station objectForKey:@"latitude"];
            NSNumber* longitudeNumber = [station objectForKey:@"longitude"];
            
            CLLocation* stationLocation = [[CLLocation new] initWithLatitude:[latitudeNumber doubleValue] longitude:[longitudeNumber doubleValue]];
            CLLocationDistance distance = [currentLocation distanceFromLocation:stationLocation];
            [station setValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
        }
    }
    
    // sort stations by distance from current location
    NSArray* sortedStations = [rawStations sortedArrayUsingFunction:compareDistance context:nil];
    
    // filter stations based on filter string.
    NSMutableArray* newStations = [NSMutableArray array];
    for (NSDictionary* station in sortedStations) 
    {
        if ([self filterStation:station]) 
        {
            [newStations addObject:station];
        }
    }
    
    // replace current stations list.
    [stations release];
    stations = [newStations retain];
    
    // reload view
    [self.tableView reloadData];
}

- (BOOL)doesStation:(NSDictionary*)station containKeyword:(NSString*)keyword 
{
    // check if the filter text is in the station name
    if ([station stationName] && [[station stationName] rangeOfString:keyword options:NSCaseInsensitiveSearch].length) return YES;
    
    // check if the filter text is in the address
    if ([station address] && [[station address] rangeOfString:keyword options:NSCaseInsensitiveSearch].length) return YES;
    
    if ([station tags]) 
    {
        // check if any of the tags match
        for (NSString* tag in [station tags])
        {
            if ([tag rangeOfString:keyword options:NSCaseInsensitiveSearch].length) return YES;
        }
    }
    
    return NO;
}

- (BOOL)filterStation:(NSDictionary *)station
{
    if (!filter) return YES;
    
    // split filter to words and see if this station match all the words.
    NSArray* keywords = [filter componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for (NSString* keyword in keywords)
    {
        // trim any whitespace from the keyword
        keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // skip empty keywords.
        if (!keyword || keyword.length == 0) continue;
        
        // if station does not contain this keyword, we can return NO already.
        if (![self doesStation:station containKeyword:keyword]) 
        {
            return NO;
        }
    }
    
    // station contains all keywords, it should be included in the list.
    return YES;
}

- (void)about:(id)sender
{
    [SendFeedback open];
}

- (void)keyboardDidShow:(NSNotification*)n
{
    CGRect keyboardRect = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, 
                                  _tableView.frame.origin.y, 
                                  _tableView.frame.size.width, 
                                  _tableView.frame.size.height - keyboardRect.size.height);
}

- (void)keyboardWillHide:(NSNotification*)n
{
    CGRect keyboardRect = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, 
                                  _tableView.frame.origin.y, 
                                  _tableView.frame.size.width, 
                                  _tableView.frame.size.height + keyboardRect.size.height);
}

- (void)hideSearchBarAnimated:(BOOL)animated
{
    [_tableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:animated];
}

- (void)settingsChanged:(NSNotification*)n
{
    [self refreshStations:nil];
}

@end