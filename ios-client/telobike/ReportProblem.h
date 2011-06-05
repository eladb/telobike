//
//  ReportProblem.h
//  telobike
//
//  Created by eladb on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface ReportProblem : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) UIViewController* parentViewController;
@property (nonatomic, retain) NSDictionary* station;

- (id)initWithParent:(UIViewController*)parentViewController station:(NSDictionary*)station;

- (void)show;

@end
