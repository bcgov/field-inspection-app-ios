//
//  NSObject.swift
//  Essentials
//
//  Created by Micha Volin on 2017-05-27.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension NSObject{
	public func addObserver(_ selector: Selector,_ name: String){
		NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
	}
}

