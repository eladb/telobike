//
//  TBStationDetailsView.m
//  telobike
//
//  Created by Elad Ben-Israel on 10/2/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBStationDetailsView.h"
#import "UIColor+Style.h"
#import "TBTintedView.h"
#import "TBFavorites.h"

@interface TBStationDetailsView() <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIView* parkingContainerView;
@property (strong, nonatomic) IBOutlet UIView* bikeContainerView;

@property (strong, nonatomic) IBOutlet UILabel* availSpaceLabel;
@property (strong, nonatomic) IBOutlet UILabel* availBikeLabel;

@property (strong, nonatomic) IBOutlet UILabel* stationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* stationAddressLabel;

@property (strong, nonatomic) IBOutlet TBTintedView* indicatorView;
@property (strong, nonatomic) IBOutlet TBTintedView* topIndicatorView;

@end

@implementation TBStationDetailsView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setStation:(TBStation *)station {
    _station = station;

    self.stationNameLabel.textColor = [UIColor detailsTintColor];
    
//    self.indicatorView.fillColor = station.indicatorColor;
//    self.topIndicatorView.fillColor = [UIColor grayColor];
    self.indicatorView.hidden = YES;
    self.topIndicatorView.fillColor = station.indicatorColor;

    self.availSpaceLabel.text = [NSString stringWithFormat:@"%ld", (long)station.availSpace];
    self.availBikeLabel.text = [NSString stringWithFormat:@"%ld", (long)station.availBike];
    
    self.parkingContainerView.layer.cornerRadius = 0.0f;
    self.bikeContainerView.layer.cornerRadius = 0.0f;
//    self.parkingContainerView.layer.borderWidth = 1.0f;
//    self.parkingContainerView.layer.borderColor = [[UIColor grayColor] CGColor];
//    self.bikeContainerView.layer.borderColor = self.parkingContainerView.layer.borderColor;
//    self.bikeContainerView.layer.borderWidth = self.parkingContainerView.layer.borderWidth;
    
    self.parkingContainerView.backgroundColor = station.availSpaceColor;
    self.bikeContainerView.backgroundColor = station.availBikeColor;
    
    self.stationNameLabel.text = station.stationName;
    self.stationAddressLabel.text = station.address;
}

- (IBAction)action:(id)sender {
    [self.stationDetailsDelegate stationDetailsActionClicked:self];
//
//    NSString* favoritesToggleAction = self.station.isFavorite ?
//        NSLocalizedString(@"Remove from Favorites", @"station action: remove from favorites") :
//        NSLocalizedString(@"Add to Favorites", @"station action: add to favorites");
//    
//    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                             delegate:self
//                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"station action cancel button")
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:favoritesToggleAction,
//                                                                      NSLocalizedString(@"Navigate", @"station action: navigate"),
//                                  nil];
//
//    [actionSheet showInView:self.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // favorites toggle
        [self.station setFavorite:!self.station.isFavorite];
        return;
    }
    
    if (buttonIndex == 1) { // navigte
        
    }
}


@end
