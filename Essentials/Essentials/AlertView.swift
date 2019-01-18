//
//  AlertView.swift
//  Essentials
//
//  Created by Micha Volin on 2017-05-07.
//  Copyright © 2017 Vmee. All rights reserved.
//

/**
Displays alert message under TopLayoutGuide of specified viewController.

NOTE: use 'present' class function to present AlertView.

Ex: AlertView.present(_:)
*/

public class AlertView: UIViewWithXib {
    
	@IBOutlet private var label: UILabel!
    
	class public func present(on controller: UIViewController?, with text: String?, delay: Double = 4, offsetY: CGFloat = -20) {
        
		guard let controller = controller else {
            return
        }
        
		let alert = AlertView(frame: CGRect.zero)
		alert.translatesAutoresizingMaskIntoConstraints = false
		alert.label.text = text
		controller.view.addSubview(alert)
		alert.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: offsetY).isActive = true
		alert.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: 20).isActive = true
		alert.rightAnchor.constraint(equalTo: controller.view.rightAnchor, constant: -20).isActive = true
		UIView.animate(withDuration: 0.3, delay: delay, options: .curveLinear, animations: {
			alert.alpha = 0
		}, completion: { (success) in
			alert.removeFromSuperview()
		})
	}
}
