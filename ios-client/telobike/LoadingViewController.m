//
//  LoadingViewController.m
//  telobike
//
//  Created by eladb on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"


@implementation LoadingViewController

@synthesize loadingText=_loadingText;

- (void)dealloc
{
    [_loadingText release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _loadingText.text = NSLocalizedString(@"LOADING", nil);
}


@end
