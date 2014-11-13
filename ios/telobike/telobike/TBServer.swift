//
//  TBServer.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/19/14.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBServer: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let server = AFHTTPRequestOperationManager(baseURL: NSURL(string: "http://telobike.citylifeapps.com"))
    
    var stations: [TBStation] = []
    var city: TBCity? = nil
    
    dynamic var stationsUpdateTime = NSDate()
    dynamic var cityUpdateTime = NSDate()
    
    class var instance: TBServer {
        struct Singleton { static let instance = TBServer() }
        return Singleton.instance
    }
    
    private override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

        self.parseCityResponse(NSUserDefaults.standardUserDefaults().dictionaryForKey("city"))
        var cachedStationsResponse = NSUserDefaults.standardUserDefaults().arrayForKey("stations")
        
        // populate from bundled sample data
        if cachedStationsResponse == nil {
            if let sampleDataURL = NSBundle.mainBundle().URLForResource("sample-data", withExtension: "json") {
                let sampleData = NSData(contentsOfURL: sampleDataURL)!
                let options = NSJSONReadingOptions(0)
                cachedStationsResponse = NSJSONSerialization.JSONObjectWithData(sampleData, options: options, error: nil) as? [AnyObject]
            }
        }
        
        self.parseStationsResponse(cachedStationsResponse)
        self.reloadStations()
        self.reloadCity()
    }

    func reloadStations(completion: () -> () = {}) {
        self.server.GET("/tlv/stations", parameters: nil, success: { (_, responseObject) in
            self.parseStationsResponse(responseObject)
            NSUserDefaults.standardUserDefaults().setObject(responseObject, forKey: "stations")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.stationsUpdateTime = NSDate()
            completion()
        }, { (_, error) in
            println("error loading stations: \(error)")
            completion()
        })
    }
    
    func reloadCity(completion: () -> () = {}) {
        self.server.GET("/cities/tlv", parameters: nil, success: { (_, responseObject) in
            self.parseCityResponse(responseObject)
            NSUserDefaults.standardUserDefaults().setObject(responseObject, forKey: "city")
            NSUserDefaults.standardUserDefaults().synchronize()
            completion();
        }, { (_, error) in
            println("error loading city: \(error)")
            completion();
        })
    }

    func postPushToken(token: String, completion: () ->() = {}) {
        self.server.POST("/push/token=\(token)", parameters: nil, success: { (_, _) in
            println("push token posted successfully")
        }, { (_, error) in
            println("error posting push token: \(error)");
        })
    }
    
    var currentLocation: CLLocation? {
        return self.locationManager.location
    }
    
    func currentDistanceFromLocation(location: CLLocation) -> CLLocationDistance {
        let currentLocation = self.currentLocation ?? TBServer.instance.city?.cityCenter
        return location.distanceFromLocation(currentLocation)
    }
    
    func sortStationsByDistance(stations: [TBStation]) -> [TBStation] {
        return sorted(stations) { (s1, s2) -> Bool in
            let d1 = self.currentDistanceFromLocation(s1.location)
            let d2 = self.currentDistanceFromLocation(s2.location)
            return d1 > d2
        }
    }
    
    private func parseStationsResponse(responseObject: AnyObject?) {
        if let array = responseObject as? Array<NSDictionary> {
            
            // create a map sid -> station so we can reuse station objects in case they already exist
            var stationByID: [String:TBStation] = [:]
            for station in self.stations {
                stationByID[station.sid] = station
            }

            for dict in array {
                if let station = TBStation.stationFromDictionary(dict) {
                    // if station already exists, just update its data
                    if let existingStation = stationByID[station.sid] {
                        var mutableDict = NSMutableDictionary()
                        mutableDict.addEntriesFromDictionary(dict)
                        mutableDict["available_bike"] = 1
                        existingStation.updateDictionary(dict)
                    }
                    else {
                        self.stations.append(station)
                    }
                }
                else {
                    println("warning: cannot parse station from dictionary: \(dict)")
                }
            }
            
            self.stationsUpdateTime = NSDate()
        }
    }

    private func parseCityResponse(responseObject: AnyObject?) {
        if let dict = responseObject as? NSDictionary {
            self.city = TBCity(dictionary: dict)
            self.cityUpdateTime = NSDate()
        }
    }
}