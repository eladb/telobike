//
//  StationSearch.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/18/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

extension TBStation {
    func queryKeyword(var keyword: String) -> Bool {
        if keyword.isEmpty {
            return true
        }
        
        keyword = keyword.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let matches = self.stringsIndex.filter { (x) -> Bool in
            if let r = x.rangeOfString(keyword, options: .CaseInsensitiveSearch) {
                return !r.isEmpty
            }
            else {
                return false
            }
        }
        
        return matches.count > 0
    }
}

extension NSArray {
    func filteredStationsArrayWithQuery(query: String) -> NSArray {
        return self.filteredArrayUsingPredicate(NSPredicate(block: { (x, _) -> Bool in
            let station: TBStation = x as! TBStation
            
            if query.isEmpty {
                return true
            }
            
            let keywords = query.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            for keyword in keywords {
                if !station.queryKeyword(keyword) {
                    return false
                }
            }
            
            return true
        }))
    }
}
