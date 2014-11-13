//
//  TBFeedbackActionSheet.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "telobike-Swift.h"
#import "TBFeedbackActionSheet.h"

@implementation TBFeedbackActionSheet

- (instancetype)initWithDelegate:(id<UIActionSheetDelegate>)delegate {
    self = [super initWithTitle:nil
                       delegate:delegate
              cancelButtonTitle:NSLocalizedString(@"Cancel", @"feeback action sheet cancel button")
         destructiveButtonTitle:nil
              otherButtonTitles:NSLocalizedString(@"Contact Tel-o-Fun", @"feedback action sheet option for bike service"),
                                NSLocalizedString(@"Feedback for this app", @"feedback action sheet option for app"),
                                nil];
    return self;
}

@end
