//
//  TBAvailabilityView.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/17/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class TBAvailabilityView: UIView {
    
    var alignCenter = false

    var station: TBStation? {
        didSet {
            self.backgroundColor = UIColor.clearColor()
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        if let station = self.station {
            
            let ctx = UIGraphicsGetCurrentContext()
            
            let availSpace = station.availSpace
            var availBike = station.availBike
            var totalSlots = availSpace + availBike
            
            let spacing: CGFloat = 3.5
            let slotSize: CGFloat = rect.size.height - spacing
            let startX: CGFloat = 1.0
            let startY: CGFloat = rect.size.height / 2.0 - slotSize / 2.0 + 1.0
            var x = startX
            var y = startY
            
            let maxSlots = Int(rect.size.width / (slotSize + spacing))
            let percentageThreshold = 10
            
            // if we have more slots that we can display we do not display
            // the discrete number but rather percentage. however, we want to
            // do this only in case we have *enough* bike/spaces. this is because
            // users can discern a small amount with a quick look but not a large
            // amount (10 in our case).
            if totalSlots > maxSlots {
                // use percentage in case we have enough bike/spaces
                if availBike > percentageThreshold && availSpace > percentageThreshold {
                    availBike = (availBike / totalSlots) * maxSlots
                }
                
                // in case we have a small number of bike/spaces we would like
                // to show the exact number. for bike, availBike will already
                // be that number. for availSpace, we translate it to bike.
                if availSpace <= percentageThreshold {
                    availBike = maxSlots - availSpace
                }
                
                totalSlots = maxSlots
            }
            
            if self.alignCenter {
                x = rect.size.width / 2.0 - (CGFloat(totalSlots) * (slotSize + spacing)) / 2.0
            }
            
            for i in 0..<totalSlots {
                if i < availBike {
                    CGContextSetLineWidth(ctx, 1.0)
                    CGContextSetStrokeColorWithColor(ctx, station.fullSlotColor.CGColor)
                    CGContextSetFillColorWithColor(ctx, station.fullSlotColor.CGColor)
                }
                else {
                    CGContextSetLineWidth(ctx, 1.0)
                    CGContextSetStrokeColorWithColor(ctx, station.emptySlotColor.CGColor)
                    CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
                }
                
                let slotRect = CGRectMake(x, y, slotSize, slotSize)
                let path = UIBezierPath(roundedRect: slotRect, cornerRadius: slotRect.size.width / 2.0)
                path.fill()
                path.stroke()
                
                x += slotSize + spacing
                
                // line wrap
                if x + slotSize > rect.size.width {
                    x = startX
                    y += slotSize + spacing
                }
            }
            
        }
    }
}