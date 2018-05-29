//
//  CGPoint.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-11.
//  Copyright © 2017 Vmee. All rights reserved.
//
extension CGPoint{
   
   func distance(to: CGPoint) -> CGFloat{
      
      let distanceX = (to.x - x)
      let distanceY = (to.y - y)
      
      let sum = (distanceX * distanceX) + (distanceY * distanceY)
      
      return sqrt(sum)
   }
   
   
   static func - (left: CGPoint, right: CGPoint) -> CGPoint{
      
      let x = left.x - right.x
      let y = left.y - right.y
      
      return CGPoint(x: x, y: y)
   }
   
}
