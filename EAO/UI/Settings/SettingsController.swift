//
//  SettingsViewController.swift
//  EAO
//
//  Created by Work on 2017-03-03.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import Parse
final class SettingsController: UITableViewController {
    
	// MARK: IB Outlets
	@IBOutlet fileprivate var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
    }
    
	@IBAction fileprivate func logoutTapped(_ sender: UIButton) {
        
        guard Reachability.isConnectedToNetwork() else {
            self.self.presentAlert(controller: UIAlertController.noInternet)
            return
        }
        
		sender.isEnabled = false
		navigationController?.view.isUserInteractionEnabled = false
		indicator.startAnimating()
        
		PFUser.logOutInBackground { (error) in
			guard error == nil else {
				sender.isEnabled = true
				self.navigationController?.view.isUserInteractionEnabled = true
				self.indicator.stopAnimating()
				self.presentAlert(title: "Couldn't log out", message: "Error code is \((error as NSError? )?.code ?? 0)")
				return
			}
			self.dismiss(animated: true, completion: nil)
		}
	}
}
