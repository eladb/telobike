//
//  TBTimerViewController.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/17/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit
import AudioToolbox

#if DEBUG
private let timerIntervalSec: NSTimeInterval = 5
#else
private let timerIntervalSec: NSTimeInterval = 25 * 60
#endif

class TBTimerViewController: UIViewController {
    
    @IBOutlet private var counterLabel: TTCounterLabel!
    @IBOutlet private var startStopButton: UIButton!
    private var timerNotification: UILocalNotification!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.stopTimer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveLocalNotification:"), name: "didReceiveLocalNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.analyticsScreenDidAppear("timer")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didReceiveLocalNotification", object: nil)
    }
    
    @IBAction func startStopClicked(sender: AnyObject!) {
        if self.timerNotification == nil {
            self.startTimer()
        }
        else {
            self.stopTimer()
        }
    }
    
    private func startTimer() {
        self.stopTimer()
        self.startStopButton.setTitle(NSLocalizedString("Stop", comment: ""), forState: .Normal)
        self.counterLabel.start()
        
        self.timerNotification = UILocalNotification()
        self.timerNotification.fireDate = NSDate().dateByAddingTimeInterval(timerIntervalSec)
        self.timerNotification.alertBody = NSLocalizedString("Return your bicycle", comment: "")
        self.timerNotification.alertAction = NSLocalizedString("Open", comment: "")
        self.timerNotification.soundName = "bikebell.wav"
        UIApplication.sharedApplication().scheduleLocalNotification(self.timerNotification)
    }
    
    private func stopTimer() {
        self.counterLabel.stop()
        self.counterLabel.startValue = UInt64(timerIntervalSec) * 1000
        self.counterLabel.countDirection = kCountDirection.CountDirectionDown.rawValue
        self.startStopButton.setTitle(NSLocalizedString("Start", comment: ""), forState: .Normal)
        
        if (self.timerNotification != nil) {
            UIApplication.sharedApplication().cancelLocalNotification(self.timerNotification)
            self.timerNotification = nil
        }
    }
    
    // - MARK: Local Notification Handler
    
    @objc private func didReceiveLocalNotification(note: NSNotification!) {
        self.stopTimer()
        
        if UIApplication.sharedApplication().applicationState != .Active {
            return
        }
        
        if let notification = note.object as? UILocalNotification {
            if let soundName = notification.soundName, pathURL = NSBundle.mainBundle().URLForResource(soundName, withExtension: nil) {
                var audioEffect = SystemSoundID(0)
                AudioServicesCreateSystemSoundID(pathURL, &audioEffect)
                AudioServicesPlaySystemSound(audioEffect)
            }
            
            // show alert if defined
            if let alertBody = notification.alertBody {
                TBAlerts.showAlertFromViewController(self, title: alertBody)
            }
        }
    }
}
