//
//  TBFavorites.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/19/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBFavorites: NSObject {
    private var favorites = [String:Bool]()
    private let defaultsKey = "favorites"
    
    class var instance: TBFavorites {
        struct Singleton { static let instance = TBFavorites() }
        return Singleton.instance
    }
    
    override init() {
        if let dict = NSUserDefaults.standardUserDefaults().dictionaryForKey(defaultsKey) {
            self.favorites = dict as [String:Bool]
        }
    }
    
    private func defaultsKeyForStationID(stationID: String) -> String {
        return "favorite.\(stationID)"
    }

    func isFavoriteStationID(stationID: String) -> Bool {
        return self.favorites[stationID] ?? false
    }
    
    func setStationID(stationID: String, favorite isFavorite: Bool) {
        self.favorites[stationID] = isFavorite
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            NSUserDefaults.standardUserDefaults().setObject(self.favorites, forKey: self.defaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
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