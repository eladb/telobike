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
#import "TBMainViewController.h"
#import "TBFeedbackActionSheet.h"
#import "TBFeedbackMailComposeViewController.h"
#import "UIViewController+GAI.h"
#import "TBObserver.h"

@interface TBListViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray* sortedStations;
@property (strong, nonatomic) TBObserver *stationsObserver;
@end

@implementation TBListViewController

#pragma mark - View controller events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.stationsObserver = [TBObserver observerForObject:[TBServer instance] keyPath:@"stations" block:^{
        self.sortedStations = [[TBServer instance] sortStationsByDistance:[TBServer instance].stations];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];

    self.tableView.backgroundView = activityIndicator;

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

@end