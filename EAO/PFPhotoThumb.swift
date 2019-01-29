//
//  PFPhotoThumb.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Parse

final class PFPhotoThumb: PFObject, PFSubclassing {
    
    @NSManaged var id: String?
    @NSManaged var observationId: String?
    @NSManaged var index: NSNumber?
    // original asset type: "Video" "Photo"
    @NSManaged var originalType: String?
    @NSManaged var file: PFFileObject?
    @NSManaged var observation: PFObservation?

    static func parseClassName() -> String {
        return "PhotoThumb"
    }
    
    @objc static func load(for observationId: String, result: @escaping (_ photos: [PFPhotoThumb]?)->Void) {
        guard let query = PFPhotoThumb.query() else {
            result(nil)
            return
        }
        query.fromLocalDatastore()
        query.whereKey("observationId", equalTo: observationId)
        query.findObjectsInBackground(block: { (photos, error) in
            result(photos as? [PFPhotoThumb])
        })
    }
    
    @objc func get() -> Data? {
        guard let id = id else {
            return nil
        }
        let url = URL(fileURLWithPath: FileManager.workDirectory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
}

