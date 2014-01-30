//
//  TBTimerViewController.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/13/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

@import AudioToolbox;

#import "TBTimerViewController.h"
#import <TTCounterLabel.h>
#import "UIViewController+GAI.h"

#define TIMER_INTERVAL_SEC (25 * 60)

@interface TBTimerViewController ()

@property (strong, nonatomic) IBOutlet TTCounterLabel* counterLabel;
@property (strong, nonatomic) IBOutlet UIButton* startStopButton;

@property (strong, nonatomic) UILocalNotification* timerNotification;

@end

@implementation TBTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stopTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:@"didReceiveLocalNotification" object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didReceiveLocalNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self analyticsScreenDidAppear:@"timer"];
}

#pragma mark - Start/stop

- (IBAction)startStopClicked:(id)sender {
    if (!self.timerNotification) {
        [self startTimer];
    }
    else {
        [self stopTimer];
    }
}

- (void)startTimer {
    [self stopTimer];
    
    [self.startStopButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
    [self.counterLabel start];
    
    NSTimeInterval interval = TIMER_INTERVAL_SEC;
    
    self.timerNotification = [[UILocalNotification alloc] init];
    self.timerNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:interval];
    self.timerNotification.alertBody = NSLocalizedString(@"Bicycle timer elapsed", nil);
    self.timerNotification.alertAction = NSLocalizedString(@"Open", nil);
    self.timerNotification.soundName = @"bikebell.wav";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:self.timerNotification];
}

- (void)stopTimer {
    
    [self.counterLabel stop];
    self.counterLabel.startValue = TIMER_INTERVAL_SEC * 1000;
    self.counterLabel.countDirection = kCountDirectionDown;

    [self.startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    
    if (self.timerNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.timerNotification];
        self.timerNotification = nil;
    }
}

#pragma mark - Local notification handler

- (void)didReceiveLocalNotification:(NSNotification*)note {
    [self stopTimer];

    // if we came from the background, we don't need an alert because it was already displayed
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }

    UILocalNotification* notification = note.object;
    
    /* sound attribution:
     <div xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/" about="http://soundcloud.com/soundbyterfreesounds/www-soundbyter-com-bicycle-bell-sound-effect"><span property="dct:title">"www.soundbyter.com-bicycle-bell-sound-effect"</span> (<a rel="cc:attributionURL" property="cc:attributionName" href="http://soundcloud.com/soundbyterfreesounds">soundbyterfreesounds</a>) / <a rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/">CC BY-NC 3.0</a></div>
     */

    // play sound if defined
    NSString* soundName = notification.soundName;
    if (soundName) {
        NSURL* pathURL = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    
    // show alert if defined
    if (notification.alertBody) {
        [[[UIAlertView alloc] initWithTitle:notification.alertBody
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                           otherButtonTitles:nil] show];
    }
    
    [self stopTimer];
}


@end
