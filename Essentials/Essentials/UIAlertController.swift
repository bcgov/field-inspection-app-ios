//
//  UIAlertController.swift
//  Essentials
//
//  Created by Micha Volin on 2017-02-24.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UIAlertController{
	
	public func addActions(_ actions: [UIAlertAction]){
		for action in actions {
			addAction(action)
		}
	}
	
	///Generic alert. contains "Okay" action
	convenience public init(title: String?, message: String?, handler: (()->Void)?=nil){
		self.init(title: title, message: message, preferredStyle: .alert)
		let okay = UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
			handler?()
		})
		self.addAction(okay)
	}
	
	
	///Generic alert. contains "Yes" and "No" actions
	convenience public init(title: String?, message: String?, yes: @escaping (()->Void), cancel: (()->Void)?=nil){
		self.init(title: title, message: message, preferredStyle: .alert)
		let yes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
			yes()
		})
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
			cancel?()
		})
		self.addActions([yes,cancel])
	}
}
