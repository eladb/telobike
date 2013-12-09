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
#import "NSObject+Binding.h"
#import "TBMainViewController.h"
#import "TBMapViewController.h"

@interface TBFavoritesViewController ()

@property (strong, nonatomic) NSArray* favoriteStations;
@property (strong, nonatomic) IBOutlet UILabel* emptyLabel;

@end

@implementation TBFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib* nib = [UINib nibWithNibName:NSStringFromClass([TBStationTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:STATION_CELL_REUSE_IDENTIFIER];
    
    [self observeValueOfKeyPath:@"stations" object:[TBServer instance] with:^(id new, id old) {
        [self updateFavoritesWithReload:YES];
        [self.refreshControl endRefreshing];
    }];
    
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.font = [UIFont boldSystemFontOfSize:20.0f];

    
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    self.emptyLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No Favorites", nil)
                                                                     attributes:@{ NSParagraphStyleAttributeName: style }];
    self.emptyLabel.textColor = [UIColor colorWithWhite:204/255.0f alpha:1.0f];
    self.tableView.backgroundView = self.emptyLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFavoritesWithReload:YES];
}

#pragma mark - Data

- (IBAction)refresh:(id)sender {
    [[TBServer instance] reloadStations:nil];
}

- (void)updateFavoritesWithReload:(BOOL)reload {
    self.favoriteStations = [[TBServer instance].stations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TBStation* station = evaluatedObject;
        return station.isFavorite;
    }]];
    
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
    mapViewController.selectedStation = self.favoriteStations[indexPath.row];
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
