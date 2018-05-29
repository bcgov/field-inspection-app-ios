//
//  CLLocationCoordinate.swift
//  Vmee
//
//  Created by Micha Volin on 2017-01-01.
//  Copyright © 2017 Vmee. All rights reserved.
//

import MapKit
extension CLLocationCoordinate2D{
   func toCLLocation()->CLLocation{
      return CLLocation(latitude: latitude, longitude: longitude)
   }
}
