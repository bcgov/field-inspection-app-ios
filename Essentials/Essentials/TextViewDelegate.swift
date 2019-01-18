//
//  TextViewDelegate.swift
//  Essentials
//
//  Created by Micha Volin on 2017-05-28.
//  Copyright © 2017 Vmee. All rights reserved.
//

@objc
public protocol TextViewDelegate {
	@objc optional func textShouldBeginEditing(textView: TextView) -> Bool
	@objc optional func textDidFinishEditing(textView: TextView)
	@objc optional func textDidChange(textView: TextView)
	@objc optional func text(textView: UITextView, range: NSRange, replacement text: String) -> Bool
}

