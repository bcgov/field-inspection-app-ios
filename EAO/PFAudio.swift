//
//  PFAudio.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Parse

final class PFAudio: PFObject, PFSubclassing {
    
    @NSManaged var id: String?
    @NSManaged var observationId: String?
    @NSManaged var inspectionId: String?
    @NSManaged var coordinate: PFGeoPoint?
    @NSManaged var index: NSNumber?
    @NSManaged var notes: String?
    @NSManaged var title: String?
    @NSManaged var url: URL?
    @NSManaged var file: PFFileObject?
    @NSManaged var observation: PFObservation?

    static func parseClassName() -> String {
        return "Audio"
    }
    
    @objc static func load(for observationId: String, result: @escaping (_ audios: [PFAudio]?)->Void) {
        guard let query = PFAudio.query() else {
            result(nil)
            return
        }
        query.fromLocalDatastore()
        query.whereKey("observationId", equalTo: observationId)
        query.findObjectsInBackground(block: { (audios, error) in
            result(audios as? [PFAudio])
        })
    }
    
    @objc func get() -> Data? {
        guard let id = id else {
            return nil
        }
        let url = URL(fileURLWithPath: FileManager.workDirectory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
    
    @objc func getURL() -> Data? {
        guard let id = id else {
            return nil
        }
        let url = URL(fileURLWithPath: FileManager.workDirectory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
}

