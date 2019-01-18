//
//  UIButton.swift
//  Essentials
//
//  Created by Micha Volin on 2017-02-22.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UIButton {
    
    @IBInspectable var left: CGFloat {
        get {return 0}
        set {
            titleEdgeInsets.left = newValue
        }
    }
    
    @IBInspectable var numberOfLines: Int {
        get {return 0}
        set {
            self.titleLabel?.numberOfLines = newValue
        }
    }
    
    @IBInspectable var centralize: Bool {
        get {return false}
        set {
            if newValue {
                self.titleLabel?.textAlignment = .center
            }
        }
    }
}
