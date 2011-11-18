//
//  FeedbackOptions.h
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@protocol FeedbackOptionsDelegate;

@interface FeedbackOptions : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (void)showFromTabBar:(UITabBar*)tabBar;

@property (nonatomic, assign) id <FeedbackOptionsDelegate> delegate;

@end

@protocol FeedbackOptionsDelegate <NSObject>

@required
- (void)presentModalViewController:(UIViewController*)viewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;

@end