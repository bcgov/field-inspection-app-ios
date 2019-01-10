//
//  Team.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Foundation

class Team {
    var objectID: String
    var name: String
    var isActive: Bool

    init(objectID: String, name: String, isActive: Bool) {
        self.objectID = objectID
        self.name = name
        self.isActive = isActive
    }
}
