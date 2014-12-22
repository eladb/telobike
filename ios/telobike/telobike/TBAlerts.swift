//
//  TBAlerts.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/16/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class TBAlerts {
    class func showAlertFromViewController(viewController: UIViewController, title: String, message: String? = nil, dismissed: (() -> ())? = nil) {
        UIAlertView(
            title: title,
            message: message,
            delegate: AlertDelegate(callback: dismissed),
            cancelButtonTitle: NSLocalizedString("OK", comment: "")).show()
    }
    
    class func showAlert(#title: String, message: String? = nil) {
        if let vc = UIApplication.sharedApplication().keyWindow?.rootViewController {
            self.showAlertFromViewController(vc, title: title, message: message)
        }
    }
}

private class AlertDelegate: NSObject, UIAlertViewDelegate {
    private let callback: (() -> ())?
    init(callback: (() -> ())?) {
        self.callback = callback
        super.init()
        DelegateManager.ref(self)
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.callback?()
        DelegateManager.unref(self)
    }
}

private struct DelegateManager {
    private static var delegates = [AlertDelegate]()
    
    static func ref(delegate: AlertDelegate) {
        delegates.append(delegate)
    }
    
    static func unref(delegtae: AlertDelegate) {
        var idx: Int?
        
        for i in 0..<delegates.count {
            if delegates[i] === delegtae {
                idx = i
                break
            }
        }
        
        if let idx = idx {
            delegates.removeAtIndex(idx)
        }
    }
}
