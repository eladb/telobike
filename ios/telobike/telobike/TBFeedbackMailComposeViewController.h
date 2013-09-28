//
//  TBFeedbackMailComposeViewController.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "TBFeedbackActionSheet.h"

@interface TBFeedbackMailComposeViewController : MFMailComposeViewController

- (instancetype)initWithFeedbackOption:(TBFeedbackActionSheetOptions)option;

@end
