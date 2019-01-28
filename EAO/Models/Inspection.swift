//
//  Inspection.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import RealmSwift

protocol ParseFactory: class {
    func createParseObject() -> PFObject
}

class Inspection: Object {
    
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
    
    // MARK: Properties
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var userId: String?
    @objc dynamic var objectId: String?
    @objc dynamic var isSubmitted: Bool = false
    @objc dynamic var project: String?
    @objc dynamic var title: String?
    @objc dynamic var subtitle: String?
    @objc dynamic var subtext: String?
    @objc dynamic var number: String?
    @objc dynamic var start: Date?
    @objc dynamic var end: Date?
    @objc dynamic var teamID: String?
    @objc dynamic var meta: InspectionMeta?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var debugDescription: String {
        
        var parameters = [String: Any?]()
        
        parameters["title"] = title ?? "N/A"
        parameters["submitted"] = isSubmitted
        parameters["local"] = isStoredLocally
        return "\(self) \(parameters)"
    }
}

extension Inspection: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFInspection()
        // save local inspection ID
        object["localId"] = self.id
        object.userId = self.userId
        object.project = self.project
        object.title = self.title
        object.subtitle = self.subtitle
        object.subtext = self.subtext
        object.number = self.number
        object.start = self.start
        object.end = self.end

        return object
    }
}
