//
//  TBSearchResultTableViewCell.m
//  telobike
//
//  Created by Elad Ben-Israel on 1/27/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

#import "TBSearchResultTableViewCell.h"

@interface TBSearchResultTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView* iconView;
@property (strong, nonatomic) IBOutlet UILabel* resultTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel* distanceLabel;

@end

@implementation TBSearchResultTableViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.iconView.image = nil;
    self.resultTitleLabel.text = nil;
    self.distanceLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setImage:(UIImage *)image {
    self.iconView.image = image;
}

- (void)setTitle:(NSString *)title {
    self.resultTitleLabel.text = title;
}

- (void)setDetail:(NSString *)detail {
    self.distanceLabel.text = detail;
}

@end
