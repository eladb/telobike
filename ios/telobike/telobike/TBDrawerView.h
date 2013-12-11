//
//  TBDrawerView.h
//  expand
//
//  Created by Elad Ben-Israel on 12/11/13.
//  Copyright (c) 2013 Citylifeapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBDrawerView : UIView

@property (readonly, nonatomic) BOOL isOpened;

- (void)openAnimated:(BOOL)animated;
- (void)closeAnimated:(BOOL)animated;

@end
