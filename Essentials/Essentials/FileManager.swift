//
//  FileManager.swift
//  Essentials
//
//  Created by Micha Volin on 2017-05-09.
//  Copyright © 2017 Vmee. All rights reserved.
//

extension FileManager {

    static public var workDirectory: URL {

        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

