//
//  URL.swift
//  EAO
//
//  Created by Micha Volin on 2017-05-15.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

extension URL{
	public init(photoId: String){
		self.init(fileURLWithPath: FileManager.directory.absoluteString)
		appendPathComponent(photoId)
		//(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
	}
}
