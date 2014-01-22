//
//  TBListViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

@import QuartzCore;

#import "TBServer.h"
#import "TBListViewController.h"
#import "TBMapViewController.h"
#import "TBStationTableViewCell.h"
#import "TBStation.h"
#import "NSObject+Binding.h"
#import "TBMainViewController.h"
#import "TBFeedbackActionSheet.h"
#import "TBFeedbackMailComposeViewController.h"
#import "UIViewController+GAI.h"

@interface TBListViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray* sortedStations;

@end

@implementation TBListViewController

#pragma mark - View controller events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self observeValueOfKeyPath:@"stations" object:[TBServer instance] with:^(id new, id old) {
        self.sortedStations = [self sortByDistance:[TBServer instance].stations];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    UINib* nib = [UINib nibWithNibName:NSStringFromClass([TBStationTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:STATION_CELL_REUSE_IDENTIFIER];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[TBServer instance] reloadStations:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self analyticsScreenDidAppear:@"list"];
}

#pragma mark - Stations

- (IBAction)refresh:(id)sender {
    [[TBServer instance] reloadStations:nil];
}

// returns an array sorted by distance from current location (if user approved location)
- (NSArray*)sortByDistance:(NSArray*)stations {
    CLLocation* location = self.locationManager.location;
    
    // no location, sort array from north to south by fixing current location
    // to the north of city center.
    if (!location) {
        location = [[CLLocation alloc] initWithLatitude:0.0f longitude:[TBServer instance].city.cityCenter.coordinate.longitude];
    }

    return [stations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TBStation* station1 = obj1;
        TBStation* station2 = obj2;
        CLLocationDistance distance1 = [station1 distanceFromLocation:location];
        CLLocationDistance distance2 = [station2 distanceFromLocation:location];
        return distance1 - distance2;
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sortedStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBStationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STATION_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.station = self.sortedStations[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBStation* station = self.sortedStations[indexPath.row];
    TBMapViewController* mapViewController = self.main.mapViewController;
    [mapViewController selectAnnotation:station animated:NO];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

#pragma mark - Feedback

- (IBAction)feedback:(id)sender {
    TBFeedbackActionSheet* feedbackActionSheet = [[TBFeedbackActionSheet alloc] initWithDelegate:self];
    feedbackActionSheet.delegate = self;
#warning fix show from tabbar feedback
//    [feedbackActionSheet showFromTabBar:self.navigation.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    TBFeedbackMailComposeViewController* vc = [[TBFeedbackMailComposeViewController alloc] initWithFeedbackOption:(TBFeedbackActionSheetOptions)buttonIndex];
    if (!vc) {
        return; // cancel
    }
    
    vc.mailComposeDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end