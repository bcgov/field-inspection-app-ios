//
//  String.swift
//  EAO
//
//  Created by Micha Volin on 2017-06-12.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

//MARK: - Notifications
extension String{
	static let insertByDate = "insertByDate"
	static let reload       = "reload"
}

//MARK: - Local paths
extension String{
	static let projects = "projects"
}

//MARK: - Constants
extension String{
	static let name = "name"
}

func getStringSize(with size: UInt64) -> String {
    var convertedValue: Double = Double(size)
    var multiplyFactor = 0
    let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
    while convertedValue > 1024 {
        convertedValue /= 1024
        multiplyFactor += 1
    }
    return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
}
