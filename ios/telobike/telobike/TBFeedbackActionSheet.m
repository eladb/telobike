//
//  TBFeedbackActionSheet.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "TBServer.h"
#import "TBFeedbackActionSheet.h"

@implementation TBFeedbackActionSheet

- (instancetype)initWithDelegate:(id<UIActionSheetDelegate>)delegate {
    self = [super initWithTitle:NSLocalizedString(@"Send feedback for", @"feedback action sheet title")
                       delegate:delegate
              cancelButtonTitle:NSLocalizedString(@"Cancel", @"feeback action sheet cancel button")
         destructiveButtonTitle:nil
              otherButtonTitles:NSLocalizedString(@"Bicycle system", @"feedback action sheet option for bike service"),
                                NSLocalizedString(@"App", @"feedback action sheet option for app"),
                                nil];

    return self;
}

@end
