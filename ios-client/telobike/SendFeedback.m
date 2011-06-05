//
//  SendFeedback.m
//  telobike
//
//  Created by eladb on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendFeedback.h"
#import "AppDelegate.h"

@implementation SendFeedback

- (void)dealloc
{
    [_viewController release];
    [super dealloc];
}

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        _viewController = [viewController retain];
    }
    return self;
}

- (void)show
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* deviceid = [[UIDevice currentDevice] uniqueIdentifier];

    MFMailComposeViewController* mailCompose = [[[MFMailComposeViewController alloc] init] autorelease];
    [mailCompose setToRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [mailCompose setSubject:NSLocalizedString(@"telobike Feedback", @"feedback mail subject")];
    [mailCompose setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT", nil), version, deviceid] isHTML:NO];
    mailCompose.mailComposeDelegate = self;
    [_viewController presentModalViewController:mailCompose animated:YES];
    [self retain];
}

+ (void)open
{
    SendFeedback* s = [[[SendFeedback alloc] initWithParentViewController:[AppDelegate app].mainController] autorelease];
    [s show];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:NO];
    [self release];
}

@end
