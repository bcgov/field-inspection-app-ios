//
//  PFAudio.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import ObjectMapper
import RealmSwift

final class PFAudio: Object, Mappable{
    
    private struct SerializationKeys {
        static let id = "id"
        static let observationId = "observationId"
        static let inspectionId = "inspectionId"
        static let index = "index"
        static let notes = "notes"
        static let title = "title"
        static let url = "url"
        static let file = "file"
        static let coordinate = "coordinate"
    }
    
    @objc dynamic var id            : String = UUID().uuidString
    @objc dynamic var observationId : String?
    @objc dynamic var inspectionId : String?
    @objc dynamic var index: NSNumber? = 0
    @objc dynamic var notes: String?
    @objc dynamic var title: String?
    @objc dynamic var url: String?
    @objc dynamic var coordinate: RealmLocation?
    //    @objc dynamic var file : PFFile?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }

    func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        observationId <- map[SerializationKeys.observationId]
        inspectionId <- map[SerializationKeys.inspectionId]
        index <- map[SerializationKeys.index]
        notes <- map[SerializationKeys.notes]
        title <- map[SerializationKeys.title]
        url <- map[SerializationKeys.url]
        coordinate <- map[SerializationKeys.coordinate]
        //        file <- map[SerializationKeys.file]
    }
}

extension PFAudio {
    
    @objc static func load(for observationId: String, result: @escaping (_ audios: [PFAudio]?)->Void){
        //        guard let query = PFAudio.query() else{
        //            result(nil)
        //            return
        //        }
        //        query.fromLocalDatastore()
        //        query.whereKey("observationId", equalTo: observationId)
        //        query.findObjectsInBackground(block: { (audios, error) in
        //            result(audios as? [PFAudio])
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
    
    @objc func getURL() -> Data?{
        return nil
        //        guard let id = id else{
        //            return nil
        //        }
        //        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        //        return try? Data(contentsOf: url)
    }
}
