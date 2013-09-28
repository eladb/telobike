//
//  TBListViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBServer.h"
#import "TBListViewController.h"
#import "TBMapViewController.h"
#import "TBStationTableViewCell.h"
#import "TBStation.h"
#import "NSObject+Binding.h"
#import "TBNavigationController.h"
#import "TBFeedbackActionSheet.h"
#import "TBFeedbackMailComposeViewController.h"

@interface TBListViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)feedback:(id)sender;

@end

@implementation TBListViewController

#pragma mark - View controller events

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self observeValueOfKeyPath:@"stations" object:[TBServer instance] with:^(id new, id old) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    
    [self refresh:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    navigationController.tabBar.selectedItem = navigationController.listViewController.tabBarItem;
}

#pragma mark - Refresh

- (NSArray*)stations {
    return [TBServer instance].stations;
}

- (void)refresh:(id)sender {
    [[TBServer instance] reloadStations:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Station";
    TBStationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.station = [self.stations objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    TBMapViewController* mapViewController = navigationController.mapViewController;
    mapViewController.selectedStation = [self.stations objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

#pragma mark - Feedback

- (void)feedback:(id)sender {
    TBFeedbackActionSheet* feedbackActionSheet = [[TBFeedbackActionSheet alloc] initWithDelegate:self];
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    feedbackActionSheet.delegate = self;
    [feedbackActionSheet showFromTabBar:navigationController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    TBFeedbackMailComposeViewController* vc = [[TBFeedbackMailComposeViewController alloc] initWithFeedbackOption:buttonIndex];
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