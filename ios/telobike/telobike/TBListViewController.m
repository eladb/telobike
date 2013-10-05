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

@interface TBListViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar* searchBar;
@property (assign, nonatomic) BOOL isShowingSearchBar;
@property (strong, nonatomic) UIBarButtonItem* searchBarButtonItem;

- (IBAction)search:(id)sender;
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
    [self hideSearchBarAnimated:NO];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = ((TBNavigationController*)self.navigationController).tabBar.frame.size.height;
    self.tableView.contentInset = insets;
    
    self.searchBarButtonItem = self.navigationItem.leftBarButtonItem;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TBNavigationController* navigationController = (TBNavigationController*)self.navigationController;
    navigationController.tabBar.selectedItem = navigationController.listViewController.tabBarItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Refresh

- (NSArray*)stations {
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString* filter = self.searchBar.text;
        
        if (filter.length == 0) {
            return YES;
        }
        
        TBStation* station = evaluatedObject;
        
        // split filter to words and see if this station match all the words.
        NSArray* keywords = [filter componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        for (NSString* keyword in keywords) {
            if (![station queryKeyword:keyword]) {
                return NO;
            }
        }
        
        // station contains all keywords, it should be included in the list.
        return YES;
    }];
    
    return [[[TBServer instance].stations filteredArrayUsingPredicate:predicate] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TBStation* s1 = obj1;
        TBStation* s2 = obj2;
        return s2.totalSlots - s1.totalSlots;
    }];
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

#pragma mark - Search

- (void)search:(id)sender {
    if (self.tableView.contentOffset.y == -self.tableView.contentInset.top) {
        [self.searchBar becomeFirstResponder];
    }
    
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
    self.isShowingSearchBar = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.isShowingSearchBar) {
        [self.searchBar becomeFirstResponder];
        self.isShowingSearchBar = NO;
    }
}

- (void)hideSearchBarAnimated:(BOOL)animated {
    self.isShowingSearchBar = NO;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (self.searchBar.text.length == 0) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = nil;
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    [self hideSearchBarAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

@end