//
//  PhotoThumb.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import RealmSwift

class PhotoThumb: Object {
    
    //Use this variable for image caching
    var image: UIImage? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return UIImage(contentsOfFile: url.path)
    }
    
    // MARK: Properties
    @objc dynamic var id: String = "\(UUID().uuidString).jpeg"
    @objc dynamic var observationId: String?
    @objc dynamic var index: Int = 0
    // original asset type: Video? Photo?
    @objc dynamic var originalType: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }

    @objc func get() -> Data? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
}

extension PhotoThumb: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFPhotoThumb()
        // Do not set the `id` property.
//        object.observationId = self.observationId
        object.index = NSNumber(value: self.index)
        
        if let fileData = self.get() {
            object.file = PFFileObject(data: fileData)
        }
        return object
    }
}
