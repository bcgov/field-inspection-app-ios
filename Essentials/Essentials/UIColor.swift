//
//  UIColor.swift
//  Vmee
//
//  Created by Micha Volin on 2016-12-26.
//  Copyright © 2016 Vmee. All rights reserved.
//

extension UIColor {
   
   ///from 0 to 255
   convenience public init(red: Int, green: Int, blue: Int) {
      self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }
   
   convenience public init(hexadecimal: Int) {
      self.init(red: (hexadecimal >> 16) & 0xff, green: (hexadecimal >> 8) & 0xff, blue: hexadecimal & 0xff)
   }
}
