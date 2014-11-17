//
//  TBPlacemarkAnnotation.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/17/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class TBPlacemarkAnnotation: NSObject, MKAnnotation {
    let placemark: SVPlacemark
    
    init(placemark: SVPlacemark) {
        self.placemark = placemark
    }

    var coordinate: CLLocationCoordinate2D {
        return self.placemark.coordinate
    }
    
    var title: String! {
        return self.placemark.formattedAddress
    }
}
