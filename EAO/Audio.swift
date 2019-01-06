//
//  PFAudio.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-02-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import ObjectMapper
import RealmSwift

final class Audio: Object, Mappable{
    
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
    
    @objc dynamic var id            : String = "\(UUID().uuidString).mp4a"
    @objc dynamic var observationId : String?
    @objc dynamic var inspectionId : String?
    @objc dynamic var index: Int = 0
    @objc dynamic var notes: String?
    @objc dynamic var title: String?
    @objc dynamic var url: String?
    @objc dynamic var coordinate: RealmLocation?
    
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
    }
}

extension Audio {

    @objc func get() -> Data?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }

    @objc func getURL() -> URL?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return url
    }
}

