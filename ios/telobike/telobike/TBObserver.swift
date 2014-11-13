//
//  TBObserver.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/19/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

@objc class TBObserver: NSObject {
    private let object: NSObject
    private let keyPath: String
    private let block: () -> ()
    
    private init(object: NSObject, keyPath: String, block: () -> ()) {
        self.object = object
        self.keyPath = keyPath
        self.block = block
        super.init()
        self.object.addObserver(self, forKeyPath: self.keyPath, options: .Initial, context: nil)
    }
    
    deinit {
        self.object.removeObserver(self, forKeyPath: self.keyPath)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        dispatch_async(dispatch_get_main_queue(), self.block)
    }
    
    class func observerForObject(object: NSObject?, keyPath: String?, block: () -> ()) -> TBObserver? {
        if object == nil || keyPath == nil || keyPath!.isEmpty {
            return nil
        }
        return TBObserver(object: object!, keyPath: keyPath!, block: block)
    }
}