//
//  MFMailComposeViewController+Feedback.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface MFMailComposeViewController (Feedback)

+ (MFMailComposeViewController*)appFeedbackMailComposer;
+ (MFMailComposeViewController*)serviceFeedbackMailComposer;

@end
