//
//  PFUser.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-04-02.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Parse
final class User: PFUser {

    @NSManaged var access: [String: Bool]?
    @NSManaged var teams: [String]?
//    {
//        "isSuperAdmin": false,
//        "isAdmin": false,
//        "isViewOnly": false,
//        "mobileAccess": true
//    }
}
