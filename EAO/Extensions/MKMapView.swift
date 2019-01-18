//
//  MKMapView.swift
//  EAO
//
//  Created by Nicholas Palichuk on 2017-03-03.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {

    @objc class func simpleFullMap() -> MKMapView {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let mapView = MKMapView()
        
        let leftMargin: CGFloat = 0
        let topMargin: CGFloat = 0
        let mapWidth: CGFloat = screenSize.width
        let mapHeight: CGFloat = screenSize.height
        
        mapView.frame = CGRect(x: leftMargin,
                               y: topMargin,
                               width: mapWidth,
                               height: mapHeight)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        return mapView
    }
    
    @objc class func inspectionMap(tableViewYPos: CGFloat, NavigationHeight: CGFloat) -> MKMapView {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let mapView = MKMapView()
        
        let leftMargin: CGFloat = 0
        let topMargin: CGFloat = 60 + NavigationHeight
        let mapWidth: CGFloat = screenSize.width
        let mapHeight: CGFloat = tableViewYPos - 60 - NavigationHeight
        
        mapView.frame = CGRect(x: leftMargin,
                               y: topMargin,
                               width: mapWidth,
                               height: mapHeight)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        mapView.layer.masksToBounds = false
        mapView.layer.shadowColor = UIColor.tableCellShadow.cgColor
        mapView.layer.shadowOffset = CGSize(width: 0,height: 3.0)
        mapView.layer.shadowOpacity = 0.5
        mapView.layer.shadowRadius = 2.0
        
        return mapView
    }
}
