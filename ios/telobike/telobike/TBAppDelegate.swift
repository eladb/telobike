//
//  TBAppDelegate.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/13/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBAppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    private var locationManager: CLLocationManager?
    private var cityObserver: TBObserver?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        Appirater.setAppId("436915919")
        Appirater.setDaysUntilPrompt(3)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)

        // location services
        self.requestLocationServices()
        
        // analytics
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().trackerWithTrackingId("UA-27122332-1")
        
        // crashlytics
        Crashlytics.startWithAPIKey("d164a3f45648ccbfa001f8958d403135d23a4dbf")
        
        // push notifications
        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        Appirater.appLaunched(true)

        self.observeDisclaimerUpdates()

        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Appirater.appEnteredForeground(true)
        TBServer.instance.reloadStations(force: false)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("didReceiveLocalNotification", object: notification)
    }
    
    // - MARK: Utils
    
    private func showAlert(#title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    // - MARK: Disclaimer Alert
    
    private func observeDisclaimerUpdates() {
        self.cityObserver = TBObserver.observerForObject(TBServer.instance, keyPath: "city") { () -> () in
            let defaultsKey = "previous_disclaimer"
            let discl = TBServer.instance.city?.disclaimer
            var oldDiscl = NSUserDefaults.standardUserDefaults().stringForKey(defaultsKey)
            
            #if DEBUG
                oldDiscl = nil // always show disclaimer in debug mode
            #endif
            
            if oldDiscl == discl {
                return; // already showed this disclaimer
            }

            if let d = discl {
                self.showAlert(title: d)
                NSUserDefaults.standardUserDefaults().setObject(discl, forKey: defaultsKey)
            }
        }
    }
    
    // - Location Services
    
    private func requestLocationServices() {
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
        }
        
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
        if error.code == CLError.Denied.rawValue {
            self.showAlert(
                title: NSLocalizedString("Location Services Disabled for Telobike", comment: ""),
                message: NSLocalizedString("Go to the Settings app and under Privacy -> Location Services, enable Telobike", comment: ""))
        }
    }
    
    // - Push Notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = deviceToken.description
            .stringByReplacingOccurrencesOfString("<", withString: "")
            .stringByReplacingOccurrencesOfString(">", withString: "")
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        
        println("device push token: \(deviceTokenString)")
        TBServer.instance.postPushToken(deviceTokenString, completion: { () -> () in
            println("push token posted")
        })
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSString {
                self.showAlert(
                    title: NSLocalizedString("Telobike", comment: ""),
                    message: alert)
            }
        }
    }
}