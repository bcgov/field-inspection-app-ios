//
//  SettingsViewController.swift
//  EAO
//
//  Created by Work on 2017-03-03.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import Parse
final class SettingsController: UITableViewController {
	//MARK: IB Outlets
	@IBOutlet fileprivate var indicator: UIActivityIndicatorView!
	//MARK: IB Actions
	@IBAction fileprivate func logoutTapped(_ sender: UIButton) {
		if !Reachability.isConnectedToNetwork(){
			self.present(controller: UIAlertController.noInternet)
			return
		}
		sender.isEnabled = false
		navigationController?.view.isUserInteractionEnabled = false
		indicator.startAnimating()
		PFUser.logOutInBackground { (error) in
			guard error == nil else{
				sender.isEnabled = true
				self.navigationController?.view.isUserInteractionEnabled = true
				self.indicator.stopAnimating()
				self.present(controller: UIAlertController(title: "Couldn't log out", message: "Error code is \((error as NSError? )?.code ?? 0)"))
				return
			}
			self.dismiss(animated: true, completion: nil)
		}
	}
}
