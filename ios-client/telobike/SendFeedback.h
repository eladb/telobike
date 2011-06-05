//
//  SendFeedback.h
//  telobike
//
//  Created by eladb on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface SendFeedback : NSObject <MFMailComposeViewControllerDelegate>
{
    UIViewController* _viewController;
}

+ (void)open;

- (id)initWithParentViewController:(UIViewController*)viewController;
- (void)show;

@end
