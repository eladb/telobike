//
//  TimerViewController.m
//  telobike
//
//  Created by ELAD BEN-ISRAEL on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimerViewController.h"
#import "TargetConditionals.h"
#import "Analytics.h"

@implementation TimerViewController

- (void)dealloc
{
    if (notification) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
    
    [timePicker release];
    [elapsedTimeLabel release];
    [startStopButton release];
    [timer release];
    [endTimeLabel release];
    [countdownView release];
    [notification release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Timer", nil);

    // default to 25 minutes
    [timePicker setCountDownDuration:25 * 60];
    
    [startStopButton setBackgroundImage:[UIImage imageNamed:@"StartTimer.png"] forState:UIControlStateNormal];
    [startStopButton setBackgroundImage:[UIImage imageNamed:@"StartTimerH.png"] forState:UIControlStateHighlighted];
    [startStopButton setBackgroundImage:[UIImage imageNamed:@"StopTimer.png"] forState:UIControlStateSelected];
    [startStopButton setBackgroundImage:[UIImage imageNamed:@"StopTimerH.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [startStopButton setTitle:NSLocalizedString(@"TIMER_START", nil) forState:UIControlStateNormal];
    [startStopButton setTitle:NSLocalizedString(@"TIMER_START", nil) forState:UIControlStateHighlighted];
    [startStopButton setTitle:NSLocalizedString(@"TIMER_CANCEL", nil) forState:UIControlStateSelected];
    [startStopButton setTitle:NSLocalizedString(@"TIMER_CANCEL", nil) forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[Analytics shared] pageViewTimer];

    // if the timer is not started, start it.
    BOOL autoStartTimerEnabled = YES;
    NSNumber* autoStartTimer = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoStartTimer"];
    if (autoStartTimer) autoStartTimerEnabled = [autoStartTimer boolValue];
    
    if (autoStartTimerEnabled && ![self timerStarted]) {
        [self startStop:nil]; // start timer
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Timer

- (BOOL)timerStarted{
    return notification != nil;
}

- (NSTimeInterval)timeLeft
{
    if (![self timerStarted]) return 0.0;
    NSDate* endTime = [notification fireDate];
    return [endTime timeIntervalSinceNow];
}

- (void)setElapsedTimeText
{
    if (![self timerStarted]) return;
    
    NSInteger timeLeft = (NSInteger)[self timeLeft];
    NSString* elapsedText = nil;
    
    if (timeLeft > 60 * 60) {
        NSInteger hours = timeLeft / (60 * 60);
        timeLeft -= (hours * 60 * 60);
        NSInteger minutes = timeLeft / 60;
        NSInteger seconds = timeLeft % 60;
        elapsedText = [NSString stringWithFormat:@"%d:%.2d:%.2d", hours, minutes, seconds];
    }
    else {
        NSInteger minutes = timeLeft / 60;
        NSInteger seconds = timeLeft % 60;
        elapsedText = [NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds];
    }
    
    [elapsedTimeLabel setText:elapsedText];
}

- (void)startStop:(id)sender
{
    // if we have a timer, this is stop. otherwise, start.
    
    if ([self timerStarted]) {
        [[Analytics shared] eventStopTimer];

        [timer invalidate];
        [timer release];
        timer = nil;
        
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        [notification release];
        notification = nil;
        
        [timePicker setHidden:NO];
        [countdownView setHidden:YES];
        
        startStopButton.selected = NO;
    }
    else {
        [[Analytics shared] eventStopTimer];
        
#if TARGET_IPHONE_SIMULATOR
        NSTimeInterval interval = 5.0;
#else
        NSTimeInterval interval = [timePicker countDownDuration] + 1.0;
#endif
        
        notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:interval];
        notification.alertBody = NSLocalizedString(@"ALERT_BODY", nil);
        notification.alertAction = NSLocalizedString(@"ALERT_ACTION", nil);
        notification.soundName = @"bikebell.wav";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:NO repeats:YES] retain];
        [self setElapsedTimeText];
        [timePicker setHidden:YES];
        [countdownView setHidden:NO];
        startStopButton.selected = YES;
        
        NSString* endTimeText = [NSDateFormatter localizedStringFromDate:[notification fireDate] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        [endTimeLabel setText:endTimeText];
    }
}

- (void)tick:(id)sender
{
    // if time is up, stop the timer
    if ([self timeLeft] <= 0.0) {
        [self startStop:nil];
        return;
    }

    [self setElapsedTimeText];
}

@end