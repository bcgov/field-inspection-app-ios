//
//  PFPhoto.swift
//  EAO
// //  Created by Micha Volin on 2017-05-08.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import Parse

final class PFPhoto: PFObject, PFSubclassing {
    ///Use this variable for image caching
    @objc var image: UIImage?
    
    @NSManaged var id: String?
    @NSManaged var observationId: String?
    @NSManaged var photo: PFFileObject?
    @NSManaged var caption: String?
    @NSManaged var timestamp: Date?
    @NSManaged var coordinate: PFGeoPoint?
    @NSManaged var index: NSNumber?
    @NSManaged var observation: PFObservation?

    static func parseClassName() -> String {
        return "Photo"
    }
    
    @objc static func load(for observationId: String, result: @escaping (_ photos: [PFPhoto]?)->Void) {
        guard let query = PFPhoto.query() else {
            result(nil)
            return
        }
        query.fromLocalDatastore()
        query.whereKey("observationId", equalTo: observationId)
        query.findObjectsInBackground(block: { (photos, error) in
            result(photos as? [PFPhoto])
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

