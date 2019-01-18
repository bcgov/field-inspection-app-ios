//
//  UItextField.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-12.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UITextField {
   
   @IBInspectable var left: CGFloat {
      get { return 0 }
      set {

         leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: 0))
         leftViewMode = .always
      }
   }
    
    @IBInspectable var placeholderColor: UIColor {
        get { return UIColor.gray }
        set {
         
            let color = newValue.withAlphaComponent(0.5)
            let attributes = [NSAttributedStringKey.foregroundColor: color]
            guard let placeholder = placeholder else {return}
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
}
