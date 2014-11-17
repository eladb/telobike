//
//  TBTintedView.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/16/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class TBTintedView: UIView {
    var station: TBStation?
    var alignCenter = false
    var fillColor: UIColor? {
        didSet { self.setNeedsDisplay() }
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let fillColor = self.fillColor ?? UIColor.greenColor()
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor)
        UIRectFill(rect)
    }
}

