//
//  Settings.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-15.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

struct Settings {
    
    static let REALM_SCHEMA_NUMBER: UInt64 = 4
    static var shouldRotate = false
    
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return formatter
    }
}

struct Colors {
    static let Blue = UIColor(hex: "4667a2")
    static let Red = UIColor(hex: "e03850")
    static let White = UIColor(hex: "ffffff")
}
