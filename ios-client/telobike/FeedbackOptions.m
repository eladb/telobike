//
//  FeedbackOptions.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedbackOptions.h"
#import "City.h"
#import "AppDelegate.h"

@implementation FeedbackOptions

@synthesize delegate;

- (void)showFromTabBar:(UITabBar*)tabBar
{
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Feedback", nil) 
                                                              delegate:self 
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                                destructiveButtonTitle:nil 
                                                     otherButtonTitles:
                                   NSLocalizedString(@"App Feedback", nil), 
                                   NSLocalizedString(@"Service Feedback", nil),
                                   nil] autorelease];
    
    [actionSheet showFromTabBar:tabBar];
}

- (void)openMailForAppFeedback
{
    MFMailComposeViewController* viewController = [[[MFMailComposeViewController alloc] init] autorelease];
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* deviceid = [[UIDevice currentDevice] uniqueIdentifier];
    [viewController setMailComposeDelegate:self];
    [viewController setToRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [viewController setSubject:NSLocalizedString(@"Telobike App Feedback", @"feedback mail subject")];
    [viewController setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT", nil), version, deviceid] isHTML:NO];
    [delegate presentModalViewController:viewController animated:YES];
}

- (void)openMailForServiceFeedback
{
    MFMailComposeViewController* viewController = [[[MFMailComposeViewController alloc] init] autorelease];
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* deviceid = [[UIDevice currentDevice] uniqueIdentifier];
    [viewController setMailComposeDelegate:self];
    [viewController setToRecipients:[NSArray arrayWithObject:[[City instance] mail]]];
    [viewController setCcRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [viewController setSubject:NSLocalizedString(@"Service Feedback (via Telobike)", @"feedback mail subject")];
    [viewController setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT", nil), version, deviceid] isHTML:NO];
    [delegate presentModalViewController:viewController animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
    [delegate dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // app feedback
            [self openMailForAppFeedback];
            break;
            
        case 1: // service feedback
            [self openMailForServiceFeedback];
            break;
            
        default:
            break;
    }
}

@end
