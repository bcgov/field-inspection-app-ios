//
//  Observation.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-05.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import RealmSwift

class Observation: Object {
    
    // MARK: Properties
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var inspectionId: String?
    @objc dynamic var title: String?
    @objc dynamic var requirement: String?
    @objc dynamic var coordinate: RealmLocation?
    @objc dynamic var pinnedAt: Date?
    @objc dynamic var observationDescription: String?
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var modifiedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var debugDescription: String {
        
        var parameters = [String: Any?]()
        
        parameters["title"] = title ?? "N/A"
        parameters["inspectionId"] = inspectionId
        parameters["requirement"] = requirement ?? "N/A"
        parameters["observationDescription"] = observationDescription ?? "N/A"
        return "\(self) \(parameters)"
    }
}

extension Observation: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFObservation()
        object.id = self.id
        object.inspectionId = self.inspectionId
        object.title = self.title
        object.requirement = self.requirement
        object.coordinate = self.coordinate?.createParseObject()
        object.pinnedAt = self.pinnedAt
        object.observationDescription = self.observationDescription

        return object
    }
}
