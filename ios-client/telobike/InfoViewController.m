//
//  InfoViewController.m
//  telobike
//
//  Created by eladb on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "City.h"
#import "InfoViewController.h"


@implementation InfoViewController

@synthesize webView=_webView;
@synthesize activityIndicator=_activityIndicator;

- (void)dealloc
{
    [_webView release];
    [_activityIndicator release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.title = NSLocalizedString(@"INFO_TITLE", nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    _webView.delegate = self;
    _webView.alpha = 0.0;
    [self refresh:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
    _webView.alpha = 1.0;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ERROR_LOADING_INFO", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ERROR_LOADING_INFO_CANCEL", nil) otherButtonTitles:nil] autorelease] show];
    [_activityIndicator stopAnimating];
}

- (IBAction)refresh:(id)sender
{
    _webView.alpha = 0.0;
    [_activityIndicator startAnimating];
    [_webView loadRequest:[NSURLRequest requestWithURL:[City instance].infoURL]];
}

@end
