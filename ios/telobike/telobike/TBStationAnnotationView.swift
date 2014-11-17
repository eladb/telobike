//
//  TBStationAnnotationView.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/17/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import MapKit

class TBStationAnnotationView: MKAnnotationView {
    
    private var markerImageObserver: TBObserver?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.annotation = nil
        self.markerImageObserver = nil
    }
    
    var station: TBStation? {
        return self.annotation as? TBStation
    }
    
    private func selectedBoundsForStation(station: TBStation) -> CGRect {
        return CGRect(origin: CGPointZero, size: station.markerImage.size)
    }
    
    private func deselectedBoundsForStation(station: TBStation) -> CGRect {
        var r = self.selectedBoundsForStation(station)
        r.size.width *= 0.5
        r.size.height *= 0.5
        return r
    }
    
    override var annotation: MKAnnotation! {
        didSet {
            self.markerImageObserver = TBObserver.observerForObject(self.station, keyPath: "lastUpdateTime") { [weak self] in
                self?.layer.contents = self?.station?.markerImage.CGImage
                return
            }
            
            if let station = self.station {
                self.layer.bounds = self.deselectedBoundsForStation(station)
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if let station = self.station {
            var startBounds: CGRect
            var endBounds: CGRect
            
            if selected {
                startBounds = self.deselectedBoundsForStation(station)
                endBounds = self.selectedBoundsForStation(station)
            }
            else {
                startBounds = self.selectedBoundsForStation(station)
                endBounds = self.deselectedBoundsForStation(station)
            }
            
            if animated {
                let a = CABasicAnimation(keyPath: "bounds")
                a.fromValue = NSValue(CGRect: startBounds)
                a.toValue = NSValue(CGRect: endBounds)
                a.duration = 0.25
                a.removedOnCompletion = false
                a.fillMode = kCAFillModeForwards
                a.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.layer.addAnimation(a, forKey: "B")
            }
            else {
                self.layer.bounds = endBounds
                self.layer.removeAllAnimations()
            }
        }
    }
}
