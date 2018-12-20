//
//  PFPhotoThumb.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import ObjectMapper
import RealmSwift

class PFPhotoThumb: Object, Mappable{
    
    private struct SerializationKeys {
        static let id = "id"
        static let observationId = "observationId"
        static let index = "index"
        static let originalType = "originalType"
    }
    
    ///Use this variable for image caching
    @objc var image : UIImage?
    
    // MARK: Properties
    @objc dynamic var id            : String?
    @objc dynamic var observationId : String?
    @objc dynamic var index         : NSNumber?
    // original asset type: Video? Photo?
    @objc dynamic var originalType  : String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        observationId <- map[SerializationKeys.observationId]
        index <- map[SerializationKeys.index]
        originalType <- map[SerializationKeys.originalType]
    }
}

extension PFPhotoThumb {
    
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
        //        guard let id = id else{
        //            return nil
        //        }
        //        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        //        return try? Data(contentsOf: url)
        return nil
    }
    
}

//final class PFPhotoThumb: PFObject, PFSubclassing{
//    ///Use this variable for image caching
//    @objc var image : UIImage?
//
//    @NSManaged var id            : String?
//    @NSManaged var observationId : String?
//    @NSManaged var index: NSNumber?
//    // original asset type: Video? Photo?
//    @NSManaged var originalType: String?
//
//    static func parseClassName() -> String {
//        return "PhotoThumb"
//    }
//
//    @objc static func load(for observationId: String, result: @escaping (_ photos: [PFPhotoThumb]?)->Void){
//        guard let query = PFPhotoThumb.query() else{
//            result(nil)
//            return
//        }
//        query.fromLocalDatastore()
//        query.whereKey("observationId", equalTo: observationId)
//        query.findObjectsInBackground(block: { (photos, error) in
//            result(photos as? [PFPhotoThumb])
//        })
//    }
//
//    @objc func get() -> Data?{
//        guard let id = id else{
//            return nil
//        }
//        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
//        return try? Data(contentsOf: url)
//    }
//}
