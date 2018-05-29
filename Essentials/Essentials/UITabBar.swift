//
//  UITabBar.swift
//  Vmee
//
//  Created by Micha Volin on 2017-01-02.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UITabBar{
   override open func sizeThatFits(_ size: CGSize) -> CGSize {
      var sizeThatFits = super.sizeThatFits(size)
      sizeThatFits.height = 45
      return sizeThatFits
   }
}
