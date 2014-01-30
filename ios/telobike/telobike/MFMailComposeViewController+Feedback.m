//
//  MFMailComposeViewController+Feedback.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBServer.h"
#import "MFMailComposeViewController+Feedback.h"

@implementation MFMailComposeViewController (Feedback)

+ (MFMailComposeViewController*)appFeedbackMailComposer {
    MFMailComposeViewController* viewController = [[MFMailComposeViewController alloc] init];
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [viewController setToRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [viewController setSubject:NSLocalizedString(@"Telobike App Feedback", @"feedback mail subject")];
    [viewController setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT_APP", nil), version] isHTML:NO];
    return viewController;
}

+ (MFMailComposeViewController*)serviceFeedbackMailComposer {
    MFMailComposeViewController* viewController = [[MFMailComposeViewController alloc] init];
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [viewController setToRecipients:[NSArray arrayWithObject:[TBServer instance].city.mail]];
    [viewController setCcRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [viewController setSubject:NSLocalizedString(@"Service Feedback (via Telobike)", @"feedback mail subject")];
    [viewController setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT", nil), version] isHTML:NO];
    
    return viewController;
}

@end
