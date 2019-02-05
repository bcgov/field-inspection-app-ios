//
//  Photo.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import RealmSwift

class Photo: Object {
    
    //Use this variable for image caching
    var image: UIImage? {
        let url = URL(fileURLWithPath: FileManager.workDirectory.path).appendingPathComponent(id, isDirectory: false)
        return UIImage(contentsOfFile: url.path)
    }
    // MARK: Properties
    @objc dynamic var id: String = "\(UUID().uuidString).jpeg"
    @objc dynamic var observationId: String?
    @objc dynamic var caption: String?
    @objc dynamic var timestamp: Date? = Date()
    @objc dynamic var coordinate: RealmLocation?
    @objc dynamic var index: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }

    @objc func get() -> Data? {
        let url = URL(fileURLWithPath: FileManager.workDirectory.path).appendingPathComponent(id, isDirectory: false)
        return try? Data(contentsOf: url)
    }
    
    internal func remove() -> Void {
        
        do {
            let url = URL(fileURLWithPath: FileManager.workDirectory.path).appendingPathComponent(id, isDirectory: false)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch let error {
            print("\(#function) Remove photo error: \(error.localizedDescription)")
        }
    }
}

extension Photo: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFPhoto()
        // Do not set the properties: `id`, `observationId`.
        object.caption = self.caption
        object.timestamp = self.timestamp
        object.coordinate = self.coordinate?.createParseObject()
        object.index = NSNumber(value: self.index)
        
        if let fileData = self.get() {
            object.photo = PFFileObject(data: fileData)
        }

        return object
    }
}
