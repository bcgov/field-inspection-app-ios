//
//  Photo.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Photo: Object, Mappable{
    
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
    var image : UIImage?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return UIImage(contentsOfFile: url.path)
    }
    
    // MARK: Properties
    @objc dynamic var id            : String = "\(UUID().uuidString).jpeg"
    @objc dynamic var observationId : String?
    @objc dynamic var caption       : String?
    @objc dynamic var timestamp     : Date? = Date()
    @objc dynamic var coordinate    : RealmLocation?
    @objc dynamic var index         : Int = 0
    
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

extension Photo {
    
    @objc func get() -> Data?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }
    
}


