//
//  TBSearchResultTableViewCell.h
//  telobike
//
//  Created by Elad Ben-Israel on 1/27/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBSearchResultTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImage* image;
@property (copy, nonatomic) NSString* title;
@property (copy, nonatomic) NSString* detail;

@end
