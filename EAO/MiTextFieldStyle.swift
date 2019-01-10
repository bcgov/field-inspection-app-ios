//
//  MiTextFieldStyle.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-10.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class MiTextFieldStyle {
    var titleColor: UIColor?
    var inputColor: UIColor?
    var fieldBG: UIColor?
    var bgColor: UIColor?
    var height: CGFloat?
    var roundCorners: Bool?
    var borderStyle: UITextField.BorderStyle?

    init(titleColor: UIColor, inputColor: UIColor,fieldBG: UIColor, bgColor: UIColor, height: CGFloat, roundCorners: Bool) {
        self.inputColor = inputColor
        self.bgColor = bgColor
        self.fieldBG = fieldBG
        self.height = height
        self.roundCorners = roundCorners
        self.titleColor = titleColor
    }
}
