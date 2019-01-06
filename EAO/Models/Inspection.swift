//
//  Inspection.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Inspection: Object, Mappable{
    
    @objc var progress: Float = 0
    @objc var isBeingUploaded = false
    
    fileprivate var failed = [Any]()
    
    internal var isStoredLocally: Bool {
        get {
            guard let realm = try? Realm(), let inspection = realm.objects(InspectionMeta.self).filter("localId == %@", id).first else {
                return false
            }
            return inspection.isStoredLocally
        }
        
        set (value) {
            guard let realm = try? Realm(), let inspection = realm.objects(InspectionMeta.self).filter("localId == %@", id).first else {
                return
            }
            
            try? realm.write {
                inspection.isStoredLocally = value
            }
        }
    }
    
    
    private struct SerializationKeys {
        static let id = "id"
        static let userId = "userId"
        static let isSubmitted = "isSubmitted"
        static let title = "title"
        static let project = "project"
        static let subtitle = "subtitle"
        static let subtext = "subtext"
        static let number = "number"
        static let start = "start"
        static let end = "end"
        static let teamID = "teamID"
    }
    
    // MARK: Properties
    @objc dynamic var id            : String = UUID().uuidString
    @objc dynamic var userId        : String?
    @objc dynamic var isSubmitted   : Bool = false
    @objc dynamic var project       : String?
    @objc dynamic var title         : String?
    @objc dynamic var subtitle      : String?
    @objc dynamic var subtext       : String?
    @objc dynamic var number        : String?
    @objc dynamic var start         : Date?
    @objc dynamic var end           : Date?
    @objc dynamic var teamID        : String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        userId <- map[SerializationKeys.userId]
        isSubmitted <- map[SerializationKeys.isSubmitted]
        project <- map[SerializationKeys.project]
        title <- map[SerializationKeys.title]
        subtitle <- map[SerializationKeys.subtitle]
        subtext <- map[SerializationKeys.subtext]
        number <- map[SerializationKeys.number]
        start <- (map[SerializationKeys.start], DateFormatterTransform(dateFormatter: Settings.formatter))
        end <- (map[SerializationKeys.end], DateFormatterTransform(dateFormatter: Settings.formatter))
        teamID <- map[SerializationKeys.teamID]
    }
    
    override var debugDescription: String{
        
        var parameters = [String: Any?]()
        
        parameters["title"] = title ?? "N/A"
        parameters["submitted"] = isSubmitted
        parameters["local"] = isStoredLocally
        return "\(self) \(parameters)"
    }
}
