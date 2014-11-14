//
//  TBNavigationController.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/14/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBNavigationController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor        = UIColor.navigationBarBackgroundColor()
        self.navigationBar.tintColor           = UIColor.navigationBarTintColor()
        self.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.navigationBarTitleColor() ];
    }
}