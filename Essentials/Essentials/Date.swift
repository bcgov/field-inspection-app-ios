//
//  Data.swift
//  Vmee
//
//  Created by Micha Volin on 2017-02-04.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension Date{
	public func startOf() -> Date?{
		return Calendar(identifier: .gregorian).startOfDay(for: self)
	}
}
