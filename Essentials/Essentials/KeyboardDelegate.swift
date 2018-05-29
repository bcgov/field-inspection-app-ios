//
//  KeyboardDelegate.swift
//  Essentials
//
//  Created by Micha Volin on 2017-04-17.
//  Copyright © 2017 Vmee. All rights reserved.
//

fileprivate var pointer_0: UInt8 = 0
fileprivate var pointer_1: UInt8 = 1
fileprivate var pointer_2: UInt8 = 2
fileprivate var pointer_3: UInt8 = 3
fileprivate var pointer_4: UInt8 = 4
fileprivate var pointer_5: UInt8 = 5

///Usage: In ViewDidAppear, call 'addKeyboardObservers', in ViewDidDisappear, call 'removeObservers'.
@objc
public protocol KeyboardDelegate{
	@objc optional func keyboardDidShow(with height: NSNumber)
	@objc optional func keyboardWillShow(with height: NSNumber)
	@objc optional func keyboardDidHide()
	@objc optional func keyboardWillHide()
	@objc optional func keyboardDidChangeFrame(with height: NSNumber)
	@objc optional func keyboardWillChangeFrame(with height: NSNumber)
}

extension KeyboardDelegate where Self: UIViewController{
	///Call in viewWillAppear
	public func addKeyboardObservers(){
		observer_0 = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { notification in
			guard let height = notification.keyboardHeight else { return }
			let float = Float(height)
			self.keyboardDidShow?(with: NSNumber(value: float))
		}
		observer_1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { notification in
			guard let height = notification.keyboardHeight else { return }
			let float = Float(height)
			self.keyboardWillShow?(with: NSNumber(value: float))
		}
		observer_2 = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: nil) { notification in
			self.keyboardDidHide?()
		}
		observer_3 = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { notification in
			self.keyboardWillHide?()
		}
		observer_4 = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil, queue: nil) { notification in
			guard let height = notification.keyboardHeight else { return }
			let float = Float(height)
			self.keyboardDidChangeFrame?(with: NSNumber(value: float))
		}
		observer_5 = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { notification in
			guard let height = notification.keyboardHeight else { return }
			let float = Float(height)
			self.keyboardWillChangeFrame?(with: NSNumber(value: float))
		}
	}
	///Call in viewWillDisappear
	public func removeKeyboardObservers(){
		if let observer_0 = observer_0 {
			NotificationCenter.default.removeObserver(observer_0)
		}
		if let observer_1 = observer_1 {
			NotificationCenter.default.removeObserver(observer_1)
		}
		if let observer_2 = observer_2 {
			NotificationCenter.default.removeObserver(observer_2)
		}
		if let observer_3 = observer_3 {
			NotificationCenter.default.removeObserver(observer_3)
		}
		if let observer_4 = observer_4 {
			NotificationCenter.default.removeObserver(observer_4)
		}
		if let observer_5 = observer_5 {
			NotificationCenter.default.removeObserver(observer_5)
		}
		observer_0 = nil
		observer_1 = nil
		observer_2 = nil
		observer_3 = nil
		observer_4 = nil
		observer_5 = nil
	}
}

extension KeyboardDelegate where Self: UIViewController{
	fileprivate var observer_0: NSObjectProtocol? {
		get {
			return objc_getAssociatedObject(self, &pointer_0) as? NSObjectProtocol
		} set {
			objc_setAssociatedObject(self, &pointer_0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	fileprivate var observer_1: NSObjectProtocol? {
		get {
			return objc_getAssociatedObject(self, &pointer_1) as? NSObjectProtocol
		} set {
			objc_setAssociatedObject(self, &pointer_1, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	fileprivate var observer_2: NSObjectProtocol? {
		get {
			return objc_getAssociatedObject(self, &pointer_2) as? NSObjectProtocol
		} set {
			objc_setAssociatedObject(self, &pointer_2, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	fileprivate var observer_3: NSObjectProtocol? {
		get {
			return objc_getAssociatedObject(self, &pointer_3) as? NSObjectProtocol
		} set {
			objc_setAssociatedObject(self, &pointer_3, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	fileprivate var observer_4: NSObjectProtocol? {
		get {
			return objc_getAssociatedObject(self, &pointer_4) as? NSObjectProtocol
		} set {
			objc_setAssociatedObject(self, &pointer_4, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	fileprivate var observer_5: NSObjectProtocol? {
		get {
			return objc_getAssociatedObject(self, &pointer_5) as? NSObjectProtocol
		} set {
			objc_setAssociatedObject(self, &pointer_5, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}


