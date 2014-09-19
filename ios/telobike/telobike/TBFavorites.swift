//
//  TBFavorites.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/19/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

@objc class TBFavorites: NSObject {
    class var instance: TBFavorites {
        struct Singleton { static let instance = TBFavorites() }
        return Singleton.instance
    }
    
    private func defaultsKeyForStationID(stationID: String) -> String {
        return "favorite.\(stationID)"
    }

    func isFavoriteStationID(stationID: String) -> Bool {
        NSUserDefaults.standardUserDefaults().synchronize()
        return NSUserDefaults.standardUserDefaults().boolForKey(self.defaultsKeyForStationID(stationID))
    }
    
    func setStationID(stationID: String, favorite isFavorite: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(isFavorite, forKey: self.defaultsKeyForStationID(stationID))
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

extension TBStation {
    var favorite: Bool {
        get { return TBFavorites.instance.isFavoriteStationID(self.sid) }
        set { TBFavorites.instance.setStationID(self.sid, favorite: newValue) }
    }
    
    var isFavorite: Bool {
        return self.favorite
    }
}