//
//  TextViewController.swift
//  EAO
//
//  Created by Micha Volin on 2017-05-28.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

///This is a ViewController is designed to let users input large amount of text. It can auto-rotate.
final class TextViewController: UIViewController {

    // MARK: IB Outlets
    @IBOutlet fileprivate var textView: UITextView!

	// MARK: Properties
	@objc var result: ((_ text: String?)->Void)?
	@objc var initialText: String?
	@objc var isReadOnly = false
    
	// MARK: -
	override func viewDidLoad() {
		textView.text = initialText
		navigationItem.setHidesBackButton(true, animated: false)
		if isReadOnly {
			textView.isEditable = false
		}
	}
    
	override func viewWillDisappear(_ animated: Bool) {
		removeKeyboardObservers()
		AppDelegate.reference?.shouldRotate = false
		let value =  UIInterfaceOrientation.portrait.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
		UIViewController.attemptRotationToDeviceOrientation()
	}
    
	override func viewWillAppear(_ animated: Bool) {
		addKeyboardObservers()
		AppDelegate.reference?.shouldRotate = true
		textView.becomeFirstResponder()
	}
    
    // MARK: IB Actions
    @IBAction fileprivate func doneTapped(_ sender: UIBarButtonItem) {
        result?(textView.text)
        popViewController()
    }
}

// MARK: - KeyboardDelegate
extension TextViewController: KeyboardDelegate {
    
	func keyboardWillShow(with height: NSNumber) {
		textView.contentInset.bottom = CGFloat(height.intValue + 60)
	}
}

// MARK: - UITextViewDelegate
extension TextViewController: UITextViewDelegate {
    
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		var length = textView.text?.count ?? 0
		length += text.count
		length -= range.length
		if length < 5000 {
			return true  
		} else {
			presentAlert(title: "Text Limit Exceeded", message: "You've reached maximum number of characters allowed")
			return false
		}
	}
}
