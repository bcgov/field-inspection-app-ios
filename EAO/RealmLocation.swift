//
//  RealmLocation.swift
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
    
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    required convenience init?(location: CLLocation?) {
        if let location = location {
            self.init()
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        } else {
            return nil
        }
    }
    
    func mapping(map: Map) {
        latitude <- map[SerializationKeys.latitude]
        longitude <- map[SerializationKeys.longitude]
    }
    
    func printableString() -> String? {
        
        let precision = 5
        return "Lat:\(String(format: "%\(precision)f", latitude)); Long: \(String(format: "%\(precision)f", longitude))"
    }
    
    private func round(num: Double, toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (num * divisor).rounded() / divisor
    }
}

extension RealmLocation {
    
    func createParseObject() -> PFGeoPoint {
        
        let object = PFGeoPoint()
        object.latitude = self.latitude
        object.longitude = self.longitude

        return object
    }
}
