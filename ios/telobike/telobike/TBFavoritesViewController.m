//
//  TBFavoritesViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/6/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBFavoritesViewController.h"
#import "TBStationTableViewCell.h"
#import "TBServer.h"
#import "TBStation.h"
#import "TBFavorites.h"
#import "TBMainViewController.h"
#import "TBMapViewController.h"
#import "UIViewController+GAI.h"
#import "TBObserver.h"

@interface TBFavoritesViewController ()

@property (strong, nonatomic) NSArray* favoriteStations;
@property (strong, nonatomic) UIView* emptyLabel;
@property (strong, nonatomic) TBObserver *stationsObserver;

@end

@implementation TBFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib* nib = [UINib nibWithNibName:NSStringFromClass([TBStationTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:STATION_CELL_REUSE_IDENTIFIER];
    
    self.stationsObserver = [TBObserver observerForObject:[TBServer instance] keyPath:@"stations" block:^{
        [self updateFavoritesWithReload:YES];
        [self.refreshControl endRefreshing];
    }];
    
    self.emptyLabel = [[NSBundle mainBundle] loadNibNamed:@"NoFavoritesView" owner:nil options:nil][0];
    self.tableView.backgroundView = self.emptyLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFavoritesWithReload:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self analyticsScreenDidAppear:@"favorites"];
}

#pragma mark - Data

- (IBAction)refresh:(id)sender {
    [[TBServer instance] reloadStations:nil];
}

- (void)updateFavoritesWithReload:(BOOL)reload {
    NSArray* favorites = [[TBServer instance].stations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TBStation* station = evaluatedObject;
        return station.isFavorite;
    }]];
    
    self.favoriteStations = [[TBServer instance] sortStationsByDistance:favorites];
    
    self.emptyLabel.hidden = self.favoriteStations.count > 0;
    self.tableView.scrollEnabled = self.emptyLabel.hidden;
    
    if (reload) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoriteStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBStationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:STATION_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.station = self.favoriteStations[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMapViewController* mapViewController = self.main.mapViewController;
    [mapViewController selectAnnotation:self.favoriteStations[indexPath.row] animated:NO];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

#pragma mark - Swipe to remove

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.favoriteStations[indexPath.row] setFavorite:NO];
        [self updateFavoritesWithReload:NO];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
        return;
    }
}


@end
