//
//  PFTeam.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2019-01-27.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import Parse

final class PFTeam: PFObject, PFSubclassing {

    @NSManaged var id: String?
    @NSManaged var color: String?
    @NSManaged var badge: PFFileObject?
    @NSManaged var users: [PFObject]
    @NSManaged var name: String?
    @NSManaged var isActive: NSNumber?
    @NSManaged var teamAdmin: PFObject?
    
    static func parseClassName() -> String {
        return "Team"
    }
}
