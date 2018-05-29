//
//  MVGradientView.swift
//  WineInsider
//
//  Created by Micha Volin on 2017-01-13.
//  Copyright © 2017 Spencer Mandrusiak. All rights reserved.
//

@IBDesignable
class GradientView: UIView {
   
    @IBInspectable var startColor : UIColor = UIColor.white
    @IBInspectable var endColor   : UIColor = UIColor.black
 
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let space  = CGColorSpaceCreateDeviceRGB()
        let colors = [startColor.cgColor, endColor.cgColor] as CFArray
       
        let locations : [CGFloat] = [0.0, 1.0]
        
        if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locations){
           
            let end = CGPoint(x: rect.maxX, y: rect.maxY)
            context.drawLinearGradient(gradient, start: CGPoint.zero, end: end, options: .drawsAfterEndLocation)
        }
   
    }
}
