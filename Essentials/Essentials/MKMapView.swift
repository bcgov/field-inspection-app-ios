//
//  MKMapView.swift
//  Vmee
//
//  Created by Micha Volin on 2016-12-31.
//  Copyright © 2016 Vmee. All rights reserved.
//

import  MapKit

extension MKMapView{
   public func setCurrentRegion(_ location: CLLocation?){
      guard let coordinate = location?.coordinate else{
         return
      }
      
      let latitude  = coordinate.latitude
      let longitude = coordinate.longitude
      let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
      let region = MKCoordinateRegion(center: location, span: span)
      
      setRegion(region, animated: true)
   }
   
   public func regionWithRange(range: Double) -> MKCoordinateRegion{
      let coordinate = self.userLocation.coordinate
    
      let span = MKCoordinateSpanMake(range, range)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      
      return region
      
   }
    
    public func coordinate(from: CGPoint) -> CLLocation {
        let coordinate2D = convert(CGPoint.zero, toCoordinateFrom: self)
        let location = coordinate2D.toCLLocation()
        return location
    }
}
