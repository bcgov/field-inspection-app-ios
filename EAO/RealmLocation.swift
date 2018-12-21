//
//  PFInspectionError.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-15.
//  Copyright © 2018 Goverment BC. All rights reserved.
//

import ObjectMapper
import RealmSwift

class RealmLocation: Object, Mappable {
    
    private struct SerializationKeys {
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    @objc dynamic var latitude : NSNumber? = 0
    @objc dynamic var longitude : NSNumber? = 0
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        latitude <- map[SerializationKeys.latitude]
        longitude <- map[SerializationKeys.longitude]
    }
    
    func printableString() -> String? {
        
        let precision = 5
        
        if let latitude = latitude?.doubleValue,
            let longitude = longitude?.doubleValue {
            
            return "Lat:\(String(format: "%\(precision)f", latitude)); Long: \(String(format: "%\(precision)f", longitude))"
        }
        return nil
    }
    
    private func round(num:Double, toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (num * divisor).rounded() / divisor
    }
    
    
}
