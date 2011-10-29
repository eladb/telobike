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

- (id)init
{
  self = [super init];
  if (self)
  {
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* deviceid = [[UIDevice currentDevice] uniqueIdentifier];
    [self setToRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [self setSubject:NSLocalizedString(@"telobike Feedback", @"feedback mail subject")];
    [self setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"MAIL_BODY_FMT", nil), version, deviceid] isHTML:NO];
  }
  return self;
}

@end