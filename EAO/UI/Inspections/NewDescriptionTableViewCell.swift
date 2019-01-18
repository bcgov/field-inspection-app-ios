//
//  NewDescriptionTableViewCell.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit

class NewDescriptionTableViewCell: BaseFormCell {

    @IBOutlet weak var stampDate: UIButton!
    @IBOutlet weak var stampGPS: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var topContainer: UIView!

    var currentLocation: String = ""

    let locationManager = CLLocationManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleContainer(view: container.layer)
        roundContainer(view: topContainer.layer)
        roundContainer(view: textView.layer)
        topContainer.backgroundColor = UIColor(hex: "4667a2")
        label.textColor = UIColor(hex: "cddfff")
        stampDate.setTitleColor(UIColor.white, for: .normal)
        stampGPS.setTitleColor(UIColor.white, for: .normal)
        textView.delegate = self
        setUpLocation()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUp(text: String) {
        textView.text = text
    }

    @IBAction func addGPSStamp(_ sender: Any) {
        if textView.text.isEmpty {
            textView.text = textView.text + "\(currentLocation)\n"
        } else {
            textView.text = textView.text + "\n\(currentLocation)\n"
        }
        let vc = self.parentViewController as? NewObservationElementFormViewController
        vc?.elementnewDescription = textView.text
    }

    @IBAction func addDateStamp(_ sender: Any) {
        if textView.text.isEmpty {
            textView.text = textView.text + "\(getCurrentDate())\n"
        } else {
            textView.text = textView.text + "\n\(getCurrentDate())\n"
        }
        let vc = self.parentViewController as? NewObservationElementFormViewController
        vc?.elementnewDescription = textView.text
    }

    func getCurrentDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY"
        return dateFormatter.string(from: date)
    }
}

extension NewDescriptionTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let vc = self.parentViewController as? NewObservationElementFormViewController
        vc?.elementnewDescription = textView.text
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let vc = self.parentViewController as? NewObservationElementFormViewController
        vc?.elementnewDescription = textView.text
    }
}

extension NewDescriptionTableViewCell: CLLocationManagerDelegate {
    
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
        if let location = locations.first {
            let lat: Double = round(num: location.coordinate.latitude, toPlaces: 5)
            let long: Double = round(num: location.coordinate.longitude, toPlaces: 5)
            self.currentLocation = "Lat: \(lat), Long: \(long)"
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
                                                message: "In order to register a location for the new element, we need your location.",
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
