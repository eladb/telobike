//
//  TBAlerts.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/16/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class TBAlerts {
    class func showAlertFromViewController(viewController: UIViewController, title: String, message: String? = nil, dismissed: () -> () = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: dismissed)
    }
    
    class func showAlert(#title: String, message: String? = nil) {
        if let vc = UIApplication.sharedApplication().keyWindow?.rootViewController {
            self.showAlertFromViewController(vc, title: title, message: message)
        }
    }
}
