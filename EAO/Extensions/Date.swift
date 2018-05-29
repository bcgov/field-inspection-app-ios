//
//  Date.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-15.
//  Copyright © 2017 FreshWorks. All rights reserved.
//


extension Date{
    public func timeStampFormat() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM d, HH:mm:s, y"
        return dateFormatter.string(from: self)
    }
	
	public func datePickerFormat() -> String{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE MMM dd, YYYY"
		return dateFormatter.string(from: self)
	}
	
	public func inspectionFormat() -> String{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM dd, YYYY"
		return dateFormatter.string(from: self)
	}
}
