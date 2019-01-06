//
//  PFVideo.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-19.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import RealmSwift

final class Video: Object{
    
    @objc dynamic var id            : String = "\(UUID().uuidString).mp4"
    @objc dynamic var observationId : String?
    @objc dynamic var inspectionId : String?
    @objc dynamic var index: Int = 0
    @objc dynamic var notes: String?
    @objc dynamic var title: String?
    @objc dynamic var url: String?
    @objc dynamic var coordinate: RealmLocation?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc func get() -> Data?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
    
    @objc func getURL() -> URL?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return url
    }
}

