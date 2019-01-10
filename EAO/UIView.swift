//
//  UIView.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let parentResponder = parentResponder as? UIViewController {
                return parentResponder
            }
        }
        return nil
    }
}

