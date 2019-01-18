//
//  UILabel.swift
//  EAO
//
//  Created by Micha Volin on 2017-04-07.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

extension UITextField {
	
	@objc func animate(newText: String, characterDelay: TimeInterval) {
		
		DispatchQueue.main.async {
			
			self.text = ""
			for (index, character) in newText.enumerated() {
				DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
					self.text?.append(character)
				}
			}
		}
	}
}
