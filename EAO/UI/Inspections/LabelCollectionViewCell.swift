//
//  LabelCollectionViewCell.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-17.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit

class LabelCollectionViewCell: BaseCollectionCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!
    
    let locationManager = CLLocationManager()

    override func awakeFromNib() {
        super.awakeFromNib()
        styleContainer(view: container.layer)
        roundContainer(view: label.layer)
        label.textColor = UIColor(hex: "cddfff")
    }

    func setup(location: String? = nil) {
        if location == nil {
            setUpLocation()
        } else {
            let vc = self.parentViewController as? NewObservationElementFormViewController
            vc?.currentCoordinatesString = location!
            label.text = location
        }
    }

    func setUpForViewing(location: String) {
        let vc = self.parentViewController as? NewObservationElementFormViewController
        vc?.currentCoordinatesString = location
        label.text = location
    }

    func setUpForEditing() {
        setUpLocation()
    }
}

extension LabelCollectionViewCell: CLLocationManagerDelegate {
    
    func setUpLocation() {
        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()

        // If location services is enabled get the user's location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
    }

    // Display coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat: Double = round(num: location.coordinate.latitude, toPlaces: 5)
            let long: Double = round(num: location.coordinate.longitude, toPlaces: 5)
            let stringLoc = "Lat: \(lat), Long: \(long)"
            let vc = self.parentViewController as? NewObservationElementFormViewController
            vc?.currentLocation = location
            vc?.currentCoordinatesString = stringLoc
            self.label.text = stringLoc
        }
    }

    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }

    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "Cannot add GPS tags without location access",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        alertController.addAction(openAction)

        self.parentViewController?.presentAlert(controller: alertController)
    }

    func round(num: Double, toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (num * divisor).rounded() / divisor
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
