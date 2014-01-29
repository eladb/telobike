//
//  UIAlertView+Blocks.h
//  telobike
//
//  Created by Elad Ben-Israel on 1/29/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Blocks)

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle completion:(void(^)(NSInteger buttonIndex))completion;

@end
