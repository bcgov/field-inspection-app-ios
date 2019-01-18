//
//  UserDefaults.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-21.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UserDefaults {
    
   struct Launch {
     
      static var count: Int {
         return UserDefaults.standard.integer(forKey: "launchCount")
      }
      
      ///Returns count after increment
      static func increment() -> Int {
         UserDefaults.standard.set(count+1, forKey: "launchCount")
         UserDefaults.standard.synchronize()
         return count
      }
   }
}

