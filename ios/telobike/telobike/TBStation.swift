//
//  Station.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/14/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class TBStation: NSObject {
    let kFreshnessTimeInterval: NSTimeInterval = 60 * 30; // 30 minutes
    let kMarginalBikeAmount = 3;

    var sid: String
    var stationName: String
    var location: CLLocation
    var address: String?
    var availBike: Int
    var availSpace: Int
    var indicatorColor: UIColor
    var fullSlotColor: UIColor
    var emptySlotColor: UIColor
    
    var state = StationUnknown.value
    
    var stringsIndex: [String] // strings for keyword lookup

    dynamic var lastUpdateTime: NSDate? // KVO this
    
    private override init() {
        self.sid = "0"
        self.stationName = ""
        self.location = CLLocation()
        self.availBike = 0
        self.availSpace = 0
        self.indicatorColor = UIColor.blackColor()
        self.fullSlotColor = UIColor.blackColor()
        self.emptySlotColor = UIColor.blackColor()
        self.stringsIndex = []
    }
    
    class func stationFromDictionary(dict: NSDictionary) -> TBStation? {
        var station = TBStation()
        if (!station.updateDictionary(dict)) {
            return nil
        }
        return station
    }
    
    func updateDictionary(dict: NSDictionary) -> Bool {
        if let sid = dict.stringForKey("sid") { self.sid = sid }
        else { return false }
        
        if let stationName = dict.localizedStringForKey("name") { self.stationName = stationName }
        else { return false }
        
        if let location = dict.locationForKey("location") { self.location = location }
        else { return false }
        
        self.address = nil
        if let address = dict.localizedStringForKey("address") {
            // use address only if different than station name
            if self.stationName.localizedCaseInsensitiveCompare(address) != NSComparisonResult.OrderedSame {
                self.address = address
            }
        }
        
        if let x = dict.numberForKey("available_bike") { self.availBike = x.integerValue }
        else { return false }
        
        if let x = dict.numberForKey("available_spaces") { self.availSpace = x.integerValue }
        else { return false }
        
        let lastUpdate = dict.jsonDateForKey("last_update")
        let freshness = lastUpdate?.timeIntervalSinceNow
        let isOnline = lastUpdate != nil && freshness < kFreshnessTimeInterval
        let isActive = !isOnline || availBike > 0 || availSpace > 0

        // determine state
        if !isOnline { self.state = StationUnknown.value }
        else if !isActive { self.state = StationInactive.value }
        else if self.availBike == 0 { self.state = StationEmpty.value }
        else if self.availSpace == 0 { self.state = StationFull.value }
        else if self.availBike <= kMarginalBikeAmount { self.state = StationMarginal.value }
        else if self.availSpace <= kMarginalBikeAmount { self.state = StationMarginalFull.value }
        else { self.state = StationOK.value }
        
        // determine colors
        let red = UIColor(red: 191.0/255.0, green:0.0, blue:0.0, alpha:1.0)
        let yellow = UIColor(red: 218/255.0, green:171/255.0, blue:0/255.0, alpha:1.0)
        let green = UIColor(red: 0.0, green:122.0/255.0, blue:0.0, alpha:1.0)
        let gray = UIColor(white: 0.8, alpha:1.0)

        // set red color for bike and space if either of them is 0.
        if isActive {
            func colorForAvail(availablity: Int) -> UIColor {
                switch availablity {
                case 0: return red
                case let x where x <= kMarginalBikeAmount: return yellow
                default: return green
                }
            }

            var availBikeColor = colorForAvail(self.availBike)
            var availSpaceColor = colorForAvail(self.availSpace)

            indicatorColor = {
                switch (availBikeColor, availSpaceColor) {
                case (green, green): return green
                case (red, _): return red
                case (_, red): return red
                default: return yellow
                }
            }()

            self.fullSlotColor = availBikeColor
            self.emptySlotColor = availSpaceColor == yellow ? yellow : gray;
        }

        self.lastUpdateTime = NSDate()

        for (k, v) in dict {
            if let x = v as? String {
                stringsIndex.append(x)
            }
        }
        
        return true
    }
}

extension TBStation {
    var markerImage: UIImage {
        switch state {
        case StationOK.value: return UIImage(named: "map-green.png")
        case StationEmpty.value: return UIImage(named:"map-redempty.png");
        case StationFull.value: return UIImage(named:"map-redfull.png");
        case StationInactive.value: return UIImage(named:"map-gray.png");
        case StationMarginal.value: return UIImage(named:"map-yellow.png");
        case StationMarginalFull.value: return UIImage(named: "map-yellowfull.png");
        case StationUnknown.value: fallthrough
        default: return UIImage(named: "map-black.png");
        }
    }
}

extension TBStation: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    var title: String {
        return stationName ?? NSLocalizedString("untitled", comment: "untitled station name")
    }
}