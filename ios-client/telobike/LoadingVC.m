//
//  LoadingViewController2ViewController.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 5/21/13.
//
//

#import "LoadingVC.h"

@implementation LoadingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    //
    // activity indicator

    UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y + 100);

    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];

    //
    // background

    NSString* imageName = @"Default.png";
    
    // check if we are in retina and use the proper one.
    if ([UIScreen mainScreen].bounds.size.height == 568.0f) {
        imageName = @"Default-568h.png";
    }

    UIImage* image = [UIImage imageNamed:imageName];
    UIImageView* background = [[[UIImageView alloc] initWithImage:image] autorelease];

    // move background up because it is designed for full screen and we have a status bar
    background.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
    background.contentMode = UIViewContentModeTopLeft;
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
}

@end
