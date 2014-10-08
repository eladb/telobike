//
//  City.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/18/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBCity: NSObject {
    private let dict: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dict = dictionary
    }
    
    var cityName: String {
        return self.dict.stringForKey("city_name.en").stringByReplacingOccurrencesOfString("-", withString: " ")
    }
    
    var mail: String {
        return self.dict.stringForKey("mail")
    }
    
    var serviceName: String? {
        return self.dict.localizedStringForKey("service_name")
    }
    
    var mailTags: String {
        return self.dict.stringForKey("mail_tags")
    }
    
    var cityCenter: CLLocation {
        return self.dict.locationForKey("city_center")
    }
    
    var disclaimer: String? {
        return self.dict.stringForKey("disclaimer")
    }
    
    var infoURL: NSURL? {
        return self.dict.urlForKey("info_url")
    }
    
    var region: CLCircularRegion? {
        return CLCircularRegion(
            center: self.cityCenter.coordinate,
            radius: 9108.0,
            identifier: self.cityName)
    }
}