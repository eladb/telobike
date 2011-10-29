//
//  TimerViewController.h
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController
{
    IBOutlet UIDatePicker* timePicker;
    IBOutlet UIButton* startStopButton;

    IBOutlet UIView* countdownView;
    IBOutlet UILabel* elapsedTimeLabel;
    IBOutlet UILabel* endTimeLabel;
    
    NSTimer* timer;
    
    UILocalNotification* notification;
}

- (IBAction)startStop:(id)sender;

- (BOOL)timerStarted;

@end
