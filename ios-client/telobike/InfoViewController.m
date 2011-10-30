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
@synthesize urlRequest=_urlRequest;
@synthesize delegate=_delegate;

- (void)dealloc
{
    [_urlRequest release];
    [_webView release];
    [_activityIndicator release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    self.navigationItem.title = NSLocalizedString(@"INFO_TITLE", nil);
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    
    _webView.delegate = self;
    _webView.alpha = 0.0;
    
    [self refresh:nil];
}

- (void)done:(id)sender
{
    [_delegate infoViewControllerDidClose:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
    _webView.alpha = 1.0;
    
    NSString* js = @"document.getElementsByTagName('title')[0].innerHTML";
    NSString* title = [_webView stringByEvaluatingJavaScriptFromString:js];
    
    if (title)
    {
        self.navigationItem.title = title;
    }
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
    
    if (!_urlRequest)
    {
        _urlRequest = [[NSURLRequest requestWithURL:[City instance].infoURL] retain];
    }
    
    [_webView loadRequest:_urlRequest];
}

- (IBAction)back:(id)sender
{
    [_webView goBack];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] isEqualToString:[[_urlRequest URL] absoluteString]])
    {
        return YES;
    }
    
    if ([[request URL].scheme isEqualToString:@"tel"])
    {
        return YES;
    }

    // navigate to another window
    InfoViewController* ivc = [[[InfoViewController alloc] init] autorelease];
    ivc.urlRequest = request;
    [self.navigationController pushViewController:ivc animated:YES];
    return NO;
}

@end
