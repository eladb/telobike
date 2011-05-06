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
#import "StationList.h"
#import "MapViewController.h"

@interface RootViewController (Private)

- (void)reloadStations;

@end

@implementation RootViewController

@synthesize tableView=_tableView;

- (void)dealloc
{
    [_tableView release];
    [locationManager release];
    [stations release];
    [filter release];
    [super dealloc];
}

- (void)viewDidLoad
{
    locationManager = [CLLocationManager new];
    [locationManager startUpdatingLocation];
    
    _tableView.rowHeight = [StationTableViewCell cell].frame.size.height;
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadStations];
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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

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
    
    MapViewController* mapViewController = [[[AppDelegate app].mainController viewControllers] objectAtIndex:1];
    [mapViewController selectStation:station];
    
    [[AppDelegate app].mainController setSelectedIndex:1];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [filter release];
    filter = nil;
    
    if (searchText && searchText.length) filter = [searchText retain];
    [self reloadStations];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [filter release];
    filter = nil;
    [self reloadStations];
}


#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location acquired");
    
    // stop getting location updates
    locationManager.delegate = nil;
    
    // reload stations
    [self reloadStations];
}

- (IBAction)refreshStations:(id)sender
{
    [[StationList instance] refreshStationsWithCompletion:^{
        [self reloadStations];
    }];
}

@end

@implementation RootViewController (Private)

NSInteger compareDistance(id stationObj1, id stationObj2, void* ctx)
{
    NSDictionary* station1 = stationObj1;
    NSDictionary* station2 = stationObj2;

    double dist1 = [[station1 objectForKey:@"distance"] doubleValue];
    double dist2 = [[station2 objectForKey:@"distance"] doubleValue];
    return dist1 - dist2;
}

- (void)reloadStations
{
    NSArray* rawStations = [[StationList instance] stations];
    
    // calcaulte the distance of each station from our current location (if we have)
    CLLocation* currentLocation = locationManager.location;
    if (!currentLocation)
    {
        [locationManager startUpdatingLocation];
        locationManager.delegate = self;
    }
    else
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
    
    NSMutableArray* newStations = [NSMutableArray array];
    for (NSDictionary* station in sortedStations) 
    {
        NSString* stationName = [station objectForKey:@"name"];

        BOOL includeStation = YES;
        
        if (filter) 
        {
            NSRange r = [stationName rangeOfString:filter];
            includeStation = r.length > 0;
        }
        
        if (includeStation) 
        {
            [newStations addObject:station];
        }
    }
    
    [stations release];
    stations = [newStations retain];
    
    [self.tableView reloadData];
}

@end