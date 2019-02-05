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
    @objc dynamic var index: Int = 0
    @objc dynamic var notes: String?
    @objc dynamic var title: String?
    @objc dynamic var url: String?
    @objc dynamic var coordinate: RealmLocation?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc func get() -> Data? {
        let url = URL(fileURLWithPath: FileManager.workDirectory.path).appendingPathComponent(id, isDirectory: false)
        return try? Data(contentsOf: url)
    }
    
    @objc func getURL() -> URL? {
        let url = URL(fileURLWithPath: FileManager.workDirectory.path).appendingPathComponent(id, isDirectory: false)
        return url
    }
    
    internal func remove() -> Void {
        
        do {
            let url = URL(fileURLWithPath: FileManager.workDirectory.path).appendingPathComponent(id, isDirectory: false)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch let error {
            print("\(#function) Remove video error: \(error.localizedDescription)")
        }
    }
}

extension Video: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFVideo()
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
