//
//  TBFeedbackMailComposeViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "telobike-Swift.h"
#import "TBFeedbackMailComposeViewController.h"

@implementation TBFeedbackMailComposeViewController

- (instancetype)initWithFeedbackOption:(TBFeedbackActionSheetOptions)option {
    if (option != TBFeedbackActionSheetApp && option != TBFeedbackActionSheetService) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        switch (option) {
            case TBFeedbackActionSheetService:
                [self setToRecipients:[NSArray arrayWithObject:[TBServer instance].city.mail]];
                [self setCcRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
                [self setSubject:NSLocalizedString(@"Service Feedback (via Telobike)", @"feedback mail subject")];
                [self setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT", nil), version] isHTML:NO];
                break;
                
            case TBFeedbackActionSheetApp:
                [self setToRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
                [self setSubject:NSLocalizedString(@"Telobike App Feedback", @"feedback mail subject")];
                [self setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT_APP", nil), version] isHTML:NO];
                break;
                
            default:
                break;
        }

    }
    return self;
}

@end
