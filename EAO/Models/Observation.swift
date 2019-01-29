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
    
    internal func removeLocalAssets() {

        guard let realm = try? Realm() else {
            return
        }

        let photoThumbs = realm.objects(PhotoThumb.self).filter("observationId in %@", [id])
        for photoThumb in photoThumbs {
            photoThumb.remove()
        }
    
        let photos = realm.objects(Photo.self).filter("observationId in %@", [id])
        for photo in photos {
            photo.remove()
        }
        
        let audios = realm.objects(Audio.self).filter("observationId in %@", [id])
        for audio in audios {
            audio.remove()
        }
        
        let videos = realm.objects(Video.self).filter("observationId in %@", [id])
        for video in videos {
            video.remove()
        }
    }
}

extension Observation: ParseFactory {
    
    func createParseObject() -> PFObject {
        
        let object = PFObservation()
        // Do not set the properties: `id`, `observationId`, `inspectionId`.
        object.title = self.title
        object.requirement = self.requirement
        object.coordinate = self.coordinate?.createParseObject()
        object.pinnedAt = self.pinnedAt
        object.observationDescription = self.observationDescription

        return object
    }
}
