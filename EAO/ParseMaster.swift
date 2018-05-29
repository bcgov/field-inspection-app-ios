//
//  singleTest.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-13.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Foundation
import PassKit
import Parse

class ParseMaster {
    func create(object: [String: Any], name: String) {
        var obj = PFObject(className: name)
        for (key, value) in object {
            obj[key] = value
        }
        obj.pinInBackground()
        /*
        obj.saveInBackground {
            (success: Bool, error: Error?) in
            if (success) {
                let nname = obj.objectId
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
        */
    }

//    func get(name: String, id: String) {
//        let query = PFQuery(className: name)
//        query.fromLocalDatastore()
//
//        query.getObjectInBackground(withId: id).continue({
//            (task: BFTask!) -> AnyObject! in
//            if task.error != nil {
//                // There was an error.
//                return task
//            }
//
//            // task.result will be your game score
//            return task
//        })
//    }
}
