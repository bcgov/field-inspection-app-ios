//
//  UIAlertController.swift
//  EAO
//
//  Created by Work on 2017-02-21.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import UIKit

extension UIAlertController {
	@objc static var noInternet: UIAlertController {
		return UIAlertController(title: "Network Error", message: "It seems that you don't have internet connection, please try again when you establish internet connection")
	}
}
