//
//  MiButtonStyle.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-10.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class MiButtonStyle {
    var textColor: UIColor?
    var bgColor: UIColor?
    var height: CGFloat?
    var roundCorners: Bool?

    init(textColor: UIColor, bgColor: UIColor, height: CGFloat, roundCorners: Bool) {
        self.textColor = textColor
        self.bgColor = bgColor
        self.height = height
        self.roundCorners = roundCorners
    }
}
