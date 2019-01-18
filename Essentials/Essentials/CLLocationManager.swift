//
//  CLLocationManager.swift
//  Vmee
//
//  Created by Micha Volin on 2017-01-02.
//  Copyright © 2017 Vmee. All rights reserved.
//

import MapKit
extension CLLocationManager {
    public func isAuthorized() ->Bool {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            return true
        }
        return false
    }
    
    public func coordinateAsString() -> String? {
        guard let latitude   = location?.coordinate.latitude else { return nil }
        guard let longitude  = location?.coordinate.longitude else { return nil }
        
        let componentOne = String(latitude).trimBy(numberOfChar: 10)
        let componentTwo = String(longitude).trimBy(numberOfChar: 10)
        
        let coordinate = "\(componentOne) by \(componentTwo)"
        
        return coordinate
    }
}
