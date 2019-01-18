//
//  PFVideo.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-19.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import RealmSwift

final class Video: Object {
    
    @objc dynamic var id: String = "\(UUID().uuidString).mp4"
    @objc dynamic var observationId: String?
    @objc dynamic var inspectionId: String?
    @objc dynamic var index: Int = 0
    @objc dynamic var notes: String?
    @objc dynamic var title: String?
    @objc dynamic var url: String?
    @objc dynamic var coordinate: RealmLocation?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc func get() -> Data? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
    
    @objc func getURL() -> URL? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return url
    }
}

extension Video: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFAudio()
        object.id = self.id
        object.observationId = self.observationId
        object.inspectionId = self.inspectionId
        object.notes = self.notes
        if let urlString = self.url {
            object.url = URL(string: urlString)
        }
        object.coordinate = self.coordinate?.createParseObject()
        object.index = NSNumber(value: self.index)
        
        if let fileData = self.get() {
            object.file = PFFileObject(data: fileData)
        }
        
        return object
    }
}
