//
//  FileManager.swift
//  Essentials
//
//  Created by Micha Volin on 2017-05-09.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension FileManager{
	static public var directory: URL{
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}
