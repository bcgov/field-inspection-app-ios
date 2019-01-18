//
//  PFPhoto.swift
//  EAO
//  Created by Micha Volin on 2017-05-08.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import ObjectMapper
import RealmSwift

class PFPhoto: Object, Mappable {
    
    private struct SerializationKeys {
        static let id = "id"
        static let observationId = "observationId"
        static let file = "file"
        static let caption = "caption"
        static let timestamp = "timestamp"
        static let coordinate = "coordinate"
        static let index = "index"
    }
    
    ///Use this variable for image caching
    var image: UIImage? {
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return UIImage(contentsOfFile: url.path)
    }
    
    // MARK: Properties
    @objc dynamic var id: String = "\(UUID().uuidString).jpeg"
    @objc dynamic var observationId: String?
    //    @objc dynamic var file          : PFFile?
    @objc dynamic var caption: String?
    @objc dynamic var timestamp: Date? = Date()
    @objc dynamic var coordinate: RealmLocation?
    @objc dynamic var index: Int = 0
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        observationId <- map[SerializationKeys.observationId]
        caption <- map[SerializationKeys.caption]
        coordinate <- map[SerializationKeys.coordinate]
        timestamp <- (map[SerializationKeys.timestamp], DateFormatterTransform(dateFormatter: Settings.formatter))
        index <- map[SerializationKeys.index]
    }
}

extension PFPhoto {
    
    @objc static func load(for observationId: String, result: @escaping (_ photos: [PFPhoto]?)->Void) {
        //            guard let query = PFPhoto.query() else{
        //                result(nil)
        //                return
        //            }
        //            query.fromLocalDatastore()
        //            query.whereKey("observationId", equalTo: observationId)
        //            query.findObjectsInBackground(block: { (photos, error) in
        //                result(photos as? [PFPhoto])
        //            })
    }
    
    @objc func get() -> Data? {
        //            guard let id = id else{
        //                return nil
        //            }
        //            let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        //            return try? Data(contentsOf: url)
        return nil
    }
}

//final class PFPhoto: PFObject, PFSubclassing{
//    ///Use this variable for image caching
//    @objc var image : UIImage?
//
//    @NSManaged var id            : String?
//    @NSManaged var observationId : String?
//    @NSManaged var file          : PFFile?
//    @NSManaged var caption       : String?
//    @NSManaged var timestamp     : Date?
//    @NSManaged var coordinate    : PFGeoPoint?
//    @NSManaged var index: NSNumber?
//
//    static func parseClassName() -> String {
//        return "Photo"
//    }
//
//    @objc static func load(for observationId: String, result: @escaping (_ photos: [PFPhoto]?)->Void){
//        guard let query = PFPhoto.query() else{
//            result(nil)
//            return
//        }
//        query.fromLocalDatastore()
//        query.whereKey("observationId", equalTo: observationId)
//        query.findObjectsInBackground(block: { (photos, error) in
//            result(photos as? [PFPhoto])
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
//
