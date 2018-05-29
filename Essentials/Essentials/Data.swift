//
//  Data.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-15.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension Data{
   
   func lenght() -> Int{
      let data = NSData(data: self)
      let lenght = data.length
      return lenght
   }
   
}
