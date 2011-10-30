//
//  RootViewController.m
//  telofun
//
//  Created by eladb on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RootViewController.h"
#import "StationTableViewCell.h"
#import "AppDelegate.h"
#import "City.h"
#import "StationList.h"
#import "MapViewController.h"
#import "Station.h"
#import "SendFeedback.h"
#import "IASKSettingsReader.h"
#import "AppDelegate.h"

static const NSTimeInterval kMinimumAutorefreshInterval = 5 * 60; // 5 minutes

@interface RootViewController (Private)

- (void)refreshStationsWithError:(BOOL)showError;
- (void)sortStations;
- (BOOL)doesStation:(Station*)station containKeyword:(NSString*)keyword;
- (BOOL)filterStation:(Station*)station;

// navigation bar icon handlers
- (void)refreshStations:(id)sender;

- (void)settingsChanged:(NSNotification*)n;
- (void)locationChanged:(NSNotification*)n;

@end

@implementation RootViewController

@synthesize tableView=_tableView;
@synthesize searchBar=_searchBar;
@synthesize filters=_filters;
@synthesize delegate=_delegate;

- (void)dealloc
{
    [[AppDelegate app] removeLocationChangeObserver:self];
    
    [_filters release];
    [_tableView release];
    [_searchBar release];
    [mapView release];
    [stations release];
    [filter release];
    [lastRefresh release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [[AppDelegate app] addLocationChangeObserver:self selector:@selector(locationChanged:)];
    
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:kIASKAppSettingChanged object:nil];
    
    self.navigationItem.titleView = _filters;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshStations:)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mail.png"] style:UIBarButtonItemStylePlain target:self action:@selector(about:)] autorelease];
    
    _tableView.rowHeight = [StationTableViewCell cell].frame.size.height;
    
    if (!mapView)
    {
        mapView = [MapViewController new];
    }
    
    [self hideSearchBarAnimated:NO];
    
    if (!_refreshHeaderView) 
    {
      _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
      _refreshHeaderView.delegate = self;
      [_tableView addSubview:_refreshHeaderView];
    }
  
    [self showSearchBarAnimated:NO];
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // if the last refresh was more than 5 minutes ago, refresh. otherwise, just just sort by distance.
    if (!lastRefresh || [[NSDate date] timeIntervalSinceDate:lastRefresh] > kMinimumAutorefreshInterval)
    {
        [self refreshStationsWithError:NO];
    }

    [self sortStations];
}    


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideSearchBarFirstTime:) userInfo:nil repeats:NO];
}

- (void)hideSearchBarFirstTime:(id)sender
{
    if (![_searchBar isFirstResponder]) {
        [self hideSearchBarAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    StationTableViewCell *cell = (StationTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [StationTableViewCell cell];
    }
    
    Station* station = [stations objectAtIndex:[indexPath row]];
    [cell setStation:station];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Station* station = [stations objectAtIndex:[indexPath row]];
    
    [_delegate rootViewController:self didSelectStation:station];
    /*
    [mapView selectStation:station];
    [self.navigationController pushViewController:mapView animated:YES];*/
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

#pragma mark Search

- (void)showSearchBarAnimated:(BOOL)animated
{
    [_tableView setContentOffset:CGPointMake(0, 0) animated:animated];
}

- (void)hideSearchBarAnimated:(BOOL)animated
{
    [_tableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:animated];
}

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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self searchBarSearchButtonClicked:_searchBar];
}

#pragma mark Refresh

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark Feedback

- (void)about:(id)sender
{
    [_delegate rootViewControllerDidTouchFeedback:self];
}

+ (void)showAbout
{
  AppDelegate* app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
  [app.listView about:nil];
}

@end

@implementation RootViewController (Private)

- (void)refreshStations:(id)sender
{
    [self refreshStationsWithError:YES];
}

NSInteger compareDistance(id stationObj1, id stationObj2, void* ctx)
{
    Station* station1 = stationObj1;
    Station* station2 = stationObj2;
    
    double dist1 = station1.distance;
    double dist2 = station2.distance;
    
    if ([station1 isMyLocation]) dist1 = 0.0;
    if ([station2 isMyLocation]) dist2 = 0.0;
    
    return dist1 - dist2;
}

- (void)sortStations
{
    NSArray* rawStations = [[StationList instance] stations];
    
    // calcaulte the distance of each station from our current location (if we have)
    CLLocation* currentLocation = [AppDelegate app].currentLocation;
    
    // if we have current location, add the distance of each station to the current
    // location and then it will be used for sorting.
    if (currentLocation)
    {
        for (Station* station in rawStations)
        {
            CGFloat distance = [station distanceFromLocation:currentLocation];
            [station setValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
        }
    }
    
    // sort stations by distance from current location
    NSArray* sortedStations = [rawStations sortedArrayUsingFunction:compareDistance context:nil];
    
    // filter stations based on filter string.
    NSMutableArray* newStations = [NSMutableArray array];
    
    for (Station* station in sortedStations) 
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

- (BOOL)doesStation:(Station*)station containKeyword:(NSString*)keyword 
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

- (BOOL)filterStation:(Station*)station
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissModalViewControllerAnimated:YES];
}

- (void)settingsChanged:(NSNotification*)n
{
    [self refreshStations:nil];
}

- (void)locationChanged:(NSNotification*)n
{
    [self sortStations];
}

- (void)refreshStationsWithError:(BOOL)showError
{
    _isLoading = YES;
    [[StationList instance] refreshStationsWithCompletion:^
    {
        [lastRefresh release];
        lastRefresh = [NSDate new];
        [self sortStations];
        _isLoading = NO;
        
        [_refreshHeaderView refreshLastUpdatedDate];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    } failure:^
    {
        if (showError)
        {
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Telobike", nil) message:NSLocalizedString(@"REFRESH_ERROR", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"REFRESH_ERROR_BUTTON", nil) otherButtonTitles:nil] autorelease] show];
        }
    } useCache:!showError];
}

@end