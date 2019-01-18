//
//  UIColor.swift
//  EAO
//
//  Created by Work on 2017-03-03.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import UIKit

// MARK: - Navigation
extension UIColor {
    
    @objc static var navigationBarColor: UIColor {
        return .init(hex: "013366")
//        return .init(red: 0x33/0xFF, green: 0x5b/0xFF, blue: 0x9f/0xFF, alpha: 0xFF/0xFF)
    }
    
    @objc static var navigationBarTintColor: UIColor {
        
        return .white
    }
    
    @objc static var inspectionBackground: UIColor {
        return .init(hex: "f2f2f2")
//        return .init(red: 0xF2/0xFF, green: 0xF2/0xFF, blue: 0xF2/0xFF, alpha: 0xFF/0xFF)

    }
}

// MARK: - Inpsections
extension UIColor {
    
    @objc static var tableWordColor: UIColor {
        return .init(hex: "4f4f4f")
//        return .init(red: 0x4F/0xFF, green: 0x4F/0xFF, blue: 0x4F/0xFF, alpha: 0xFF/0xFF)
    }
    
    @objc static var tableWordColor2: UIColor {
        return .init(hex: "335b9f")
//        return .init(red: 0x33/0xFF, green: 0x5b/0xFF, blue: 0x9f/0xFF, alpha: 0xFF/0xFF)

    }
    
    @objc static var tableBackgroundCell: UIColor {
        return .init(hex: "fefefe")
//        return .init(red: 0xFE/0xFF, green: 0xFE/0xFF, blue: 0xFE/0xFF, alpha: 0xFE/0xFF)

    }
    
    @objc static var tableCellShadow: UIColor {
        return .init(hex: "152455")
//        return .init(red: 0x15/0xFF, green: 0x24/0xFF, blue: 0x55/0xFF, alpha: 0xFF/0xFF)

    }
}

// MARK: - Tab Bar
extension UIColor {
    
    @objc static var tabWordColor: UIColor {
//        return .init(hex: "4f4f4f")
        return .init(white: 0xFF/0xFF, alpha: 1)
    }
    
    @objc static var tabBackgroundColor: UIColor {
        return .init(hex: "335b9f")
//        return .init(red: 0x33/0xFF, green: 0x5b/0xFF, blue: 0x9f/0xFF, alpha: 0xFF/0xFF)

    }
    
    @objc static var tabUnselectedBackgroundColor: UIColor {
//        return .init(hex: "4f4f4f")
        return .init(white: 0xEF/0xFF, alpha: 1)
    }
}

