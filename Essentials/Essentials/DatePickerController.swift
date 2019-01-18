//
//  DatePickerController.swift
//  Essentials
//
//  Created by Micha Volin on 2017-04-10.
//  Copyright © 2017 Vmee. All rights reserved.
//

/// Usage: use "present" function:
//	DatePickerController.present(on: self, minimum: Date()) { (date) in
//		print(date)
//	}
final public class DatePickerController: UIViewController {
	fileprivate var completion: ((_ date: Date?)->Void)?
	// MARK: -
	@IBOutlet private var button: UIButton!
	@IBOutlet private var datePicker: UIDatePicker!
	@IBOutlet private var container: UIView!
	@IBOutlet private var wrapper: UIView!
	@IBOutlet private var bottomConstraint: NSLayoutConstraint!
	// MARK: -
	@IBAction func tap(_ sender: UITapGestureRecognizer) {
		completion?(nil)
		dismiss()
	}
	
	@IBAction func selectTapped(_ sender: UIButton) {
		sender.isEnabled = false
		completion?(datePicker.date.startOf())
		dismiss()
	}

	// MARK: -
	///
	public static func present(on controller: UIViewController, minimum: Date? = nil ,completion: @escaping (_ date: Date?)->Void) {
		let pickerController =  DatePickerController.storyboardInstance() as! DatePickerController
		pickerController.completion = completion
		controller.addChildViewController(pickerController)
		controller.view.addSubview(pickerController.view)
		pickerController.datePicker.minimumDate = minimum ?? Date()
		pickerController.bottomConstraint.constant = 0
		UIView.animate(withDuration: 0.2) {
			pickerController.wrapper.backgroundColor = UIColor.black.withAlphaComponent(0.25)
			pickerController.view.layoutIfNeeded()
		}
	}
	
	private func dismiss() {
		self.bottomConstraint.constant = -360
		UIView.animate(withDuration: 0.2, animations: {
			self.view.layoutIfNeeded()
			self.wrapper.backgroundColor = UIColor.clear
		}) { (_) in
			self.view.removeFromSuperview()
			self.removeFromParentViewController()
		}
	}
}

