//
//  InfoViewController.h
//  telobike
//
//  Created by eladb on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewControllerDelegate;

@interface InfoViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id<InfoViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet NSURLRequest* urlRequest;
@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;

- (IBAction)refresh:(id)sender;

@end

@protocol InfoViewControllerDelegate <NSObject>

@required

- (void)infoViewControllerDidClose:(InfoViewController*)viewController;

@end