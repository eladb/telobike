//
//  TBServer.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/19/14.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBServer: NSObject, CLLocationManagerDelegate {
    private let rootURL = NSURL(string: "https://s3-eu-west-1.amazonaws.com/telobike/tlv")!
    private let locationManager = CLLocationManager()
    private let server = AFHTTPRequestOperationManager(baseURL: NSURL(string: "http://telobike.citylifeapps.com"))
    
    var stations: [TBStation] = []
    var city: TBCity? = nil
    private var reloading = false
    
    dynamic var stationsUpdateTime = NSDate.distantPast() as NSDate
    dynamic var cityUpdateTime = NSDate()
    
    static let instance = TBServer()
    
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
                let options = NSJSONReadingOptions(rawValue: 0)
                cachedStationsResponse = (try? NSJSONSerialization.JSONObjectWithData(sampleData, options: options)) as? [AnyObject]
            }
        }
        
        self.parseStationsResponse(cachedStationsResponse)
        self.reloadStations(force: true)
        self.reloadCity()
    }

    func reloadStations(force force: Bool) {
        if self.reloading {
            print("reload - in progress")
            return; // already reloading
        }
        
        if !force && abs(self.stationsUpdateTime.timeIntervalSinceNow) < 30 {
            // if update time is less than 30s, dont do anything
            return;
        }
        
        print("reload")
        self.reloading = true
        self.server.GET("/tlv/stations", parameters: nil, success: { (_, responseObject) in
            self.parseStationsResponse(responseObject)
            NSUserDefaults.standardUserDefaults().setObject(responseObject, forKey: "stations")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.stationsUpdateTime = NSDate()
            self.reloading = false
        }, failure: { (_, error) in
            print("error loading stations: \(error)")
            self.reloading = false
        })
    }
    
    func getJSON(relativeURL: String, completion: ((NSError?, AnyObject?) -> ())) {
        let url = rootURL.URLByAppendingPathComponent(relativeURL)
        let prefix = "[\(relativeURL)]"
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            let httpResponse = response as! NSHTTPURLResponse
            
            if let error = error {
                print("\(prefix) Network error: \(error)")
                completion(nil, nil)
            }
            
            print("\(prefix) Response code: \(httpResponse.statusCode)")
            
            if let data = data {
                do {
                    let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    completion(nil, object)
                }
                catch let error as NSError {
                    print("\(prefix) Serialization error: \(error)")
                    completion(error, nil)
                }
            }
        }.resume()
    
    }
    
    func reloadCity(completion: () -> () = {}) {
        getJSON("city.json") { (error, city) in
            if error != nil {
                print("Error loading city: \(error)")
                completion()
            }
            
            self.parseCityResponse(city)
            NSUserDefaults.standardUserDefaults().setObject(city, forKey: "city")
            NSUserDefaults.standardUserDefaults().synchronize()
            completion()

        }
    }

    func postPushToken(token: String, completion: () ->() = {}) {
        self.server.POST("/push/token=\(token)", parameters: nil, success: { (_, _) in
            print("push token posted successfully")
        }, failure: { (_, error) in
            print("error posting push token: \(error)");
        })
    }
    
    var currentLocation: CLLocation? {
        return self.locationManager.location
    }
    
    func currentDistanceFromLocation(location: CLLocation) -> CLLocationDistance {
        if let currentLocation = self.currentLocation ?? TBServer.instance.city?.cityCenter {
            return location.distanceFromLocation(currentLocation)
        }
        else {
            return CLLocationDistanceMax
        }
    }
    
    func sortStationsByDistance(stations: [TBStation]) -> [TBStation] {
        return stations.sort {
            let d1 = self.currentDistanceFromLocation($0.location)
            let d2 = self.currentDistanceFromLocation($1.location)
            return d1 < d2
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
                        let mutableDict = NSMutableDictionary()
                        mutableDict.addEntriesFromDictionary(dict as! [NSObject : AnyObject])
                        mutableDict["available_bike"] = 1
                        existingStation.updateDictionary(dict)
                    }
                    else {
                        self.stations.append(station)
                    }
                }
                else {
                    print("warning: cannot parse station from dictionary: \(dict)")
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