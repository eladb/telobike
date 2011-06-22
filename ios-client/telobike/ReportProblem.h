//
//  ReportProblem.h
//  telobike
//
//  Created by eladb on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "Station.h"

@interface ReportProblem : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) UIViewController* parentViewController;
@property (nonatomic, retain) Station* station;

- (id)initWithParent:(UIViewController*)parentViewController station:(Station*)station;
- (void)show;

+ (void)openWithParent:(UIViewController*)parentViewController station:(Station*)station;

@end
