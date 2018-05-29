//
//  CircularButton.swift
//  EAO
//
//  Created by Nicholas Palichuk on 2017-03-17.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import UIKit

class RingButton: UIViewWithXibAndIBDesignable {
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
	///Note: returns nil always
    @IBInspectable var text: String?{
        get{ return nil }
		set{
            label.text = newValue
        }
    }
    ///Note: returns nil always
    @IBInspectable var image: UIImage?{
        get{ return nil }
        set{
            button.setBackgroundImage(newValue, for: .normal)
		}
    }
}
