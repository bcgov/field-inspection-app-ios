//
//  Photo.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import RealmSwift

class Photo: Object{
    
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
    
    override static func primaryKey() -> String? {
        return "id"
    }

    @objc func get() -> Data?{
        let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        return try? Data(contentsOf: url)
    }

}
