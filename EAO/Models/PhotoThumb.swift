//
//  PhotoThumb.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import ObjectMapper
import RealmSwift

class PhotoThumb: Object, Mappable{
    
    private struct SerializationKeys {
        static let id = "id"
        static let observationId = "observationId"
        static let index = "index"
        static let originalType = "originalType"
    }
    
    ///Use this variable for image caching
    var image : UIImage? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return UIImage(contentsOfFile: url.path)
    }
    
    // MARK: Properties
    @objc dynamic var id            : String = "\(UUID().uuidString).jpeg"
    @objc dynamic var observationId : String?
    @objc dynamic var index         : Int = 0
    // original asset type: Video? Photo?
    @objc dynamic var originalType  : String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        observationId <- map[SerializationKeys.observationId]
        index <- map[SerializationKeys.index]
        originalType <- map[SerializationKeys.originalType]
    }
}

extension PhotoThumb {
    
    @objc static func load(for observationId: String, result: @escaping (_ photos: [PFPhotoThumb]?)->Void){
        //        guard let query = PFPhotoThumb.query() else{
        //            result(nil)
        //            return
        //        }
        //        query.fromLocalDatastore()
        //        query.whereKey("observationId", equalTo: observationId)
        //        query.findObjectsInBackground(block: { (photos, error) in
        //            result(photos as? [PFPhotoThumb])
        //        })
    }
    
    @objc func get() -> Data?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
    
}
