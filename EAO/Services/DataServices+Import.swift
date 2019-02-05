//
//  DataServices+Import.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-06.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import Foundation
import AVFoundation
import Parse
import Photos
import RealmSwift
import Alamofire
import AlamofireObjectMapper

extension DataServices {
    
    /**
     Saves an inspection object pulled from a remote Parse database to the local Realm DB
     
     - parameters:
     - inspection: Parse Inspection object
     
     - Returns: true or false. False if there are any issues adding an object
     */
    class func add(inspection pfInspection: PFInspection) -> Bool {
        
        guard let userID = PFUser.current()?.objectId else {
            return false
        }
        
        do {
            let realm = try Realm()

            //don't add existing local inspections
            if let localId = pfInspection["localId"] {
                let inspection = realm.objects(Inspection.self).filter("id in %@", [localId]).first
                if inspection != nil {
                    return false
                }
            }

            let inspection = Inspection()
            inspection.id = pfInspection.objectId ?? UUID().uuidString
            inspection.userId = userID
            inspection.isSubmitted = true
            
            inspection.project = pfInspection.project
            inspection.title = pfInspection.title
            inspection.subtitle = pfInspection.subtitle
            inspection.subtext = pfInspection.subtext
            inspection.number = pfInspection.number
            inspection.start = pfInspection.start
            inspection.end = pfInspection.end
            inspection.teamID = pfInspection.teamID
            
            let doc = InspectionMeta()
            doc.localId = inspection.id
            doc.isStoredLocally = false
            doc.modifiedAt = Date()
            
            inspection.meta = doc
            
            try realm.write {
                realm.add(inspection, update: true)
                realm.add(doc, update: true)
            }
        } catch {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /**
     Saves an observation object pulled from a remote Parse database to the local Realm DB
     
     - parameters:
     - observation: Parse observation object
     
     - Returns: true or false. False if there are any issues adding an object
     */
    class func add(observation pfobservation: PFObservation, inspectionId: String) -> Bool {
        
        do {
            let observation = Observation()
            observation.id = pfobservation.objectId ?? UUID().uuidString
            observation.inspectionId = inspectionId
            observation.title = pfobservation.title
            observation.requirement = pfobservation.requirement
            observation.coordinate = pfobservation.coordinate?.toRealmCoordinate()
            observation.pinnedAt = pfobservation.pinnedAt
            observation.observationDescription = pfobservation.observationDescription
            
            let realm = try Realm()
            try realm.write {
                realm.add(observation, update: true)
            }
        } catch let error {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /**
     Saves an photo object pulled from a remote Parse database to the local Realm DB
     
     - parameters:
     - photo: Parse observation object
     
     - Returns: true or false. False if there are any issues adding an object
     */
    class func add(photo pfPhoto: PFPhoto, observationId: String) -> Bool {

        guard let objectId = pfPhoto.objectId else {
            return false
        }
        
        do {
            let photo = Photo()
            
            photo.id = "\(objectId).jpeg"
            photo.observationId = observationId
            photo.caption = pfPhoto.caption
            photo.timestamp = pfPhoto.timestamp
            photo.coordinate = pfPhoto.coordinate?.toRealmCoordinate()
            photo.index = pfPhoto.index?.intValue ?? 0
            
            let realm = try Realm()
            try realm.write {
                realm.add(photo, update: true)
            }
        } catch let error {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }

    /**
     Saves an photothumbnail object pulled from a remote Parse database to the local Realm DB
     
     - parameters:
     - photothumbnail: Parse observation object
     
     - Returns: true or false. False if there are any issues adding an object
     */
    class func add(photoThumb pfPhotoThumb: PFPhotoThumb, observationId: String) -> Bool {
        
        guard let objectId = pfPhotoThumb.objectId else {
            return false
        }

        do {
            let photoThumb = PhotoThumb()
            photoThumb.id = "\(objectId).jpeg"
            photoThumb.observationId = observationId
            photoThumb.index = pfPhotoThumb.index?.intValue ?? 0
            photoThumb.originalType = pfPhotoThumb.originalType
            
            let realm = try Realm()
            try realm.write {
                realm.add(photoThumb, update: true)
            }
        } catch let error {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }

    /**
     Saves an audio object pulled from a remote Parse database to the local Realm DB
     
     - parameters:
     - audio: Parse audio object
     
     - Returns: true or false. False if there are any issues adding an object
     */
    class func add(audio pfAudio: PFAudio, observationId: String) -> Bool {
        
        guard let objectId = pfAudio.objectId else {
            return false
        }

        do {
            let audio = Audio()
            
            audio.id = "\(objectId).mp4a"
            audio.observationId = observationId
            audio.index = pfAudio.index?.intValue ?? 0
            audio.notes = pfAudio.notes
            audio.title = pfAudio.title
            audio.url = pfAudio.url?.absoluteString
            audio.coordinate = pfAudio.coordinate?.toRealmCoordinate()

            let realm = try Realm()
            try realm.write {
                realm.add(audio, update: true)
            }
        } catch let error {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }

    /**
     Saves an video object pulled from a remote Parse database to the local Realm DB
     
     - parameters:
     - video: Parse video object
     
     - Returns: true or false. False if there are any issues adding an object
     */
    class func add(video pfVideo: PFVideo, observationId: String) -> Bool {
        
        guard let objectId = pfVideo.objectId else {
            return false
        }

        do {
            let video = Video()
            
            video.id = "\(objectId).mp4"
            video.observationId = observationId
            video.index = pfVideo.index?.intValue ?? 0
            video.notes = pfVideo.notes
            video.title = pfVideo.title
            video.url = pfVideo.url?.absoluteString
            video.coordinate = pfVideo.coordinate?.toRealmCoordinate()
            
            let realm = try Realm()
            try realm.write {
                realm.add(video, update: true)
            }
        } catch let error {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    func fetchFullInspection(inspection: Inspection, completion: (() -> Void)? = nil) {
        
        let inspectionID = inspection.id
        
        DataServices.shared.fetchObservations(for: inspectionID) { (results) in
            print("DONE FETCHING INSPECTION 👍")
            inspection.isStoredLocally = true
            completion?()
        }
    }
    
    func fetchObservations(for inspectionId: String, completion: @escaping ((_ results: Bool) -> Void)) {
        
        guard let observationQuery = PFObservation.query() else {
            completion(false)
            return
        }
        
        let inspection = PFInspection(withoutDataWithObjectId: inspectionId)
        observationQuery.whereKey("inspection", equalTo: inspection)
        observationQuery.findObjectsInBackground(block: { (observations, error) in
            
            guard let observations = observations as? [PFObservation], observations.count > 0 else {
                completion(false)
                return
            }
            
            for observation in observations {
                guard let observationId = observation.objectId else {
                    continue
                }
                
                let _ = DataServices.add(observation: observation, inspectionId: inspectionId)
                self.fetchPhotos(for: observationId, completion: { (result) in
                    self.fetchPhotoThumbs(for: observationId, completion: { (result) in
                        self.fetchAudios(for: observationId, completion: { (result) in
                            self.fetchVideos(for: observationId, completion: { (result) in
                                completion(result)
                            })
                        })
                    })
                })
            }
        })
    }

    func fetchPhotos(for observationId: String, completion: @escaping ((_ results: Bool) -> Void)) {
        
        guard let query = PFPhoto.query() else {
            completion(false)
            return
        }
        
        let observation = PFObservation(withoutDataWithObjectId: observationId)
        query.whereKey("observation", equalTo: observation)
        query.findObjectsInBackground(block: { (array, error) in
            for object in array as? [PFPhoto] ?? [] {
                guard let remoteId = object.objectId else {
                    continue
                }
                
                let _ = DataServices.add(photo: object, observationId: observationId)
                object.photo?.getDataInBackground(block: { (data, error) in
                    if let data = data {
                        try? data.write(to: FileManager.workDirectory.appendingPathComponent("\(remoteId).jpeg", isDirectory: false))
                    }
                })
            }
            completion(true)
        })
    }
    
    func fetchPhotoThumbs(for observationId: String, completion: @escaping ((_ results: Bool) -> Void)) {
        
        guard let query = PFPhotoThumb.query() else {
            completion(false)
            return
        }
        
        let observation = PFObservation(withoutDataWithObjectId: observationId)
        query.whereKey("observation", equalTo: observation)
        query.findObjectsInBackground(block: { (array, error) in
            for object in array as? [PFPhotoThumb] ?? [] {
                guard let remoteId = object.objectId else {
                    continue
                }
                
                let _ = DataServices.add(photoThumb: object, observationId: observationId)
                object.file?.getDataInBackground(block: { (data, error) in
                    if let data = data {
                        try? data.write(to: FileManager.workDirectory.appendingPathComponent("\(remoteId).jpeg", isDirectory: false))
                    }
                })
            }
            completion(true)
        })
    }

    func fetchAudios(for observationId: String, completion: @escaping ((_ results: Bool) -> Void)) {
        
        guard let query = PFAudio.query() else {
            completion(false)
            return
        }
        
        let observation = PFObservation(withoutDataWithObjectId: observationId)
        query.whereKey("observation", equalTo: observation)
        query.findObjectsInBackground(block: { (array, error) in
            for object in array as? [PFAudio] ?? [] {
                guard let remoteId = object.objectId else {
                    continue
                }
                
                let _ = DataServices.add(audio: object, observationId: observationId)
                object.file?.getDataInBackground(block: { (data, error) in
                    if let data = data {
                        try? data.write(to: FileManager.workDirectory.appendingPathComponent("\(remoteId).mp4a", isDirectory: false))
                    }
                })
            }
            completion(true)
        })
    }

    func fetchVideos(for observationId: String, completion: @escaping ((_ results: Bool) -> Void)) {
        
        guard let query = PFVideo.query() else {
            completion(false)
            return
        }
        
        let observation = PFObservation(withoutDataWithObjectId: observationId)
        query.whereKey("observation", equalTo: observation)
        query.findObjectsInBackground(block: { (array, error) in
            for object in array as? [PFVideo] ?? [] {
                guard let remoteId = object.objectId else {
                    continue
                }
                
                let _ = DataServices.add(video: object, observationId: observationId)
                object.file?.getDataInBackground(block: { (data, error) in
                    if let data = data {
                        try? data.write(to: FileManager.workDirectory.appendingPathComponent("\(remoteId).mp4", isDirectory: false))
                    }
                })
            }
            completion(true)
        })
    }

    /**
     Delete all submitted inspections
     - Returns: true or false. False if there are any issues adding an object
     */
    func deleteAllSubmittedInspections() -> Bool {
        
        do {
            let realm = try Realm()
            let inspections = realm.objects(Inspection.self).filter("isSubmitted = %@", true)
            try realm.write {
                realm.delete(inspections)
            }
            
        } catch let error{
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }
}

