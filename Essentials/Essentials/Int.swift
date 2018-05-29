//
//  Int.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-23.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension Int{
   
   
   static postfix func ++ (value: inout Int){
      value += 1
   }
   
   
   static prefix func ++ (value: inout Int){
      value += 1
   }
}
