//
//  Extensions.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-15.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import Foundation
import CoreLocation

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension CLLocation {
    
    func printableString() -> String {
        let precision = 5
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        return "Lat:\(String(format: "%\(precision)f", latitude)); Long: \(String(format: "%\(precision)f", longitude))"
    }
}
