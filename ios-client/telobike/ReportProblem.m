//
//  ReportProblem.m
//  telobike
//
//  Created by eladb on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Station.h"
#import "City.h"
#import "ReportProblem.h"


@implementation ReportProblem

@synthesize parentViewController=_parentViewController;
@synthesize station=_station;

- (id)initWithParent:(UIViewController *)parentViewController station:(NSDictionary *)station
{
    self = [super init];
    if (self)
    {
        _parentViewController = [parentViewController retain];
        _station = [station retain];
    }
    return self;
}

- (void)dealloc
{
    [_station release];
    [_parentViewController release];
    [super dealloc];
}

+ (void)openWithParent:(UIViewController*)parentViewController station:(NSDictionary*)station
{
    [[[[ReportProblem alloc] initWithParent:parentViewController station:station] autorelease] show];
}

- (void)show
{
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] 
                                   initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"REPORT_PROBLEM_TITLE", nil), _station.stationName]
                                   delegate:self 
                                   cancelButtonTitle:NSLocalizedString(@"REPORT_PROBLEM_CANCEL", nil) 
                                   destructiveButtonTitle:nil 
                                   otherButtonTitles:NSLocalizedString(@"REPORT_PROBLEM_STATION", nil), 
                                                     NSLocalizedString(@"REPORT_PROBLEM_BIKE", nil), nil] autorelease];
    
    [actionSheet showFromTabBar:_parentViewController.tabBarController.tabBar];
    [self retain];
}

- (void)openMail:(NSString*)subject body:(NSString*)body
{
    MFMailComposeViewController* mailCompose = [[[MFMailComposeViewController alloc] init] autorelease];
    [mailCompose setToRecipients:[NSArray arrayWithObject:[City instance].mail]];
    [mailCompose setCcRecipients:[NSArray arrayWithObject:@"telobike@citylifeapps.com"]];
    [mailCompose setSubject:subject];
    
    NSString* bodyWithTags = [NSString stringWithFormat:@"%@\n\n%@", body, [City instance].mailTags];
    [mailCompose setMessageBody:bodyWithTags isHTML:NO];
    
    mailCompose.mailComposeDelegate = self;
    [_parentViewController presentModalViewController:mailCompose animated:YES];
    [self retain];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 0:
            [self openMail:NSLocalizedString(@"REPORT_PROBLEM_STATION_SUBJECT", nil)
                      body:[NSString stringWithFormat:NSLocalizedString(@"REPORT_PROBLEM_STATION_BODY_FMT", nil), [_station stationName]]];
            break;
            
        case 1:
            [self openMail:NSLocalizedString(@"REPORT_PROBLEM_BIKE_SUBJECT", nil)
                      body:[NSString stringWithFormat:NSLocalizedString(@"REPORT_PROBLEM_BIKE_BODY_FMT", nil), [_station stationName]]];
            break;
            
        default:
            break;
    }
    
    [self release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [_parentViewController dismissModalViewControllerAnimated:YES];
    [self release];
}


@end
