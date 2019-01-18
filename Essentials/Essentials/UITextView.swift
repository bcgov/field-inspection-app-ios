//
//  UITextView.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-12.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension UITextView {
   
   @IBInspectable var top: CGFloat {
      get {return 0}
      set {textContainerInset.top = newValue}
   }
   
   @IBInspectable var left: CGFloat {
      get {return 0}
      set {textContainerInset.left = newValue}
   }
   
   @IBInspectable var bottom: CGFloat {
      get {return 0}
      set {textContainerInset.bottom = newValue}
   }
   
   @IBInspectable var right: CGFloat {
      get {return 0}
      set {textContainerInset.right = newValue}
   }

	public func numberOfLines() -> Int {
		let layoutManager = self.layoutManager
		let numberOfGlyphs = layoutManager.numberOfGlyphs
		var lineRange: NSRange = NSMakeRange(0, 1)
		var index = 0
		var numberOfLines = 0

		while index < numberOfGlyphs {
			layoutManager.lineFragmentRect(
				forGlyphAt: index, effectiveRange: &lineRange
			)
			index = NSMaxRange(lineRange)
			numberOfLines += 1
		}
		return numberOfLines
	}
}
