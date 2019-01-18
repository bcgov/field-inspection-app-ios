//
//  delay.swift
//  Essentials
//
//  Created by Micha Volin on 2017-06-13.
//  Copyright © 2017 Vmee. All rights reserved.
//

public func delay(_ delay: Double, closure:@escaping ()->Void) {
	DispatchQueue.main.asyncAfter(
		deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
