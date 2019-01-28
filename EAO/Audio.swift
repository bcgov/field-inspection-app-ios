//
//  PFAudio.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import RealmSwift

final class Audio: Object {
    
    @objc dynamic var id: String = "\(UUID().uuidString).mp4a"
    @objc dynamic var observationId: String?
    @objc dynamic var index: Int = 0
    @objc dynamic var notes: String?
    @objc dynamic var title: String?
    @objc dynamic var url: String?
    @objc dynamic var coordinate: RealmLocation?
    
    override static func primaryKey() -> String? {
        return "id"
    }

    @objc func get() -> Data? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: false)
        return try? Data(contentsOf: url)
    }
    
    @objc func getURL() -> URL? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: false)
        return url
    }
}

extension Audio: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFAudio()
        // Do not set the properties: `id`, `observationId`, `inspectionId`.
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
