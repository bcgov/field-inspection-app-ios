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
    
    //MARK: - Submission
    func submit(completion: @escaping (_ success: Bool,_ error: InspectionError?)->Void, block: @escaping (_ progress : Float)->Void){
        //        var objects = [PFObject]()
        //        self.failed.removeAll()
        //        if !Reachability.isConnectedToNetwork(){
        //            block(0)
        //            completion(false, .noConnection)
        //            return
        //        }
        //        guard let id = self.id else{
        //            block(0)
        //            completion(false, .inspectionIdNotFound)
        //            return
        //        }
        //        block(0)
        //        PFObservation.load(for: id) { (observations) in
        //            guard let observations = observations, !observations.isEmpty else{
        //                block(0)
        //                completion(false, .zeroObservations)
        //                return
        //            }
        //            var counter = 0
        //            objects.append(contentsOf: observations as [PFObject])
        //            objects.insert(self as PFObject, at: 0)
        //            for observation in observations{
        //                guard let observationId = observation.id else{
        //                    self.failed.append(observation)
        //                    //also all the photos
        //                    counter += 1
        //                    if counter == observations.count{
        //                        self.save(objects: objects, completion: {
        //                            var success = true
        //                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
        //                            if self.failed.count == objects.count{
        //                                _error = PFInspectionError.fail
        //                                success = false
        //                            } else if self.failed.isEmpty{
        //                                _error = nil
        //                            }
        //                            if !self.failed.isEmpty{
        //                                success = false
        //                            }
        //                            completion(success, _error)
        //                        }, block: { (progress) in
        //                            block(progress)
        //                        })
        //                    }
        //                    continue
        //                }
        //                PFPhoto.load(for: observationId, result: { (photos) in
        //                    if let photos = photos{
        //                        photos.setPFFiles()
        //                        objects.append(contentsOf: photos as [PFObject])
        //                    }
        //                    counter += 1
        //                    if counter == observations.count{
        //                        self.save(objects: objects, completion: {
        //                            var success = true
        //                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
        //                            if self.failed.count == objects.count{
        //                                _error = PFInspectionError.fail
        //                                success = false
        //                            } else if self.failed.isEmpty{
        //                                _error = nil
        //                            }
        //                            if !self.failed.isEmpty{
        //                                success = false
        //                            }
        //                            completion(success, _error)
        //                        }, block: { (progress) in
        //                            block(progress)
        //                        })
        //                    }
        //                })
        //                //                PFAudio.load(for: observationId, result: { (audios) in
        //                //                    if let audios = audios {
        //                //                        audios.setPFFiles()
        //                //                        objects.append(contentsOf: audios as [PFObject])
        //                //                    }
        //                //                    counter += 1
        //                //                    if counter == observations.count{
        //                //                        self.save(objects: objects, completion: {
        //                //                            var success = true
        //                //                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
        //                //                            if self.failed.count == objects.count{
        //                //                                _error = PFInspectionError.fail
        //                //                                success = false
        //                //                            } else if self.failed.isEmpty{
        //                //                                _error = nil
        //                //                            }
        //                //                            if !self.failed.isEmpty{
        //                //                                success = false
        //                //                            }
        //                //                            completion(success, _error)
        //                //                        }, block: { (progress) in
        //                //                            block(progress)
        //                //                        })
        //                //                    }
        //                //                })
        //
        //                //                PFVideo.load(for: observationId, result: { (videos) in
        //                //                    if let videos = videos {
        //                //                        videos.setPFFiles()
        //                //                        objects.append(contentsOf: videos as [PFObject])
        //                //                    }
        //                //                    counter += 1
        //                //                    if counter == observations.count{
        //                //                        self.save(objects: objects, completion: {
        //                //                            var success = true
        //                //                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
        //                //                            if self.failed.count == objects.count{
        //                //                                _error = PFInspectionError.fail
        //                //                                success = false
        //                //                            } else if self.failed.isEmpty{
        //                //                                _error = nil
        //                //                            }
        //                //                            if !self.failed.isEmpty{
        //                //                                success = false
        //                //                            }
        //                //                            completion(success, _error)
        //                //                        }, block: { (progress) in
        //                //                            block(progress)
        //                //                        })
        //                //                    }
        //                //                })
        //            }
        //        }
    }
    
    fileprivate func save(objects: [Any], completion: @escaping ()->Void, block: @escaping (_ progress : Float)->Void){
        //        var object_counter = 0
        //        for object in objects{
        //
        //            (object as? PFInspection)?.isSubmitted = true
        //            object.saveInBackground(block: { (success, error) in
        //                if success && error == nil{
        //
        //                } else{
        //                    self.failed.append(object)
        //                    self.isSubmitted = false
        //                    try? self.pin()
        //                }
        //                object_counter += 1
        //                block(Float(object_counter)/Float(objects.count))
        //                if object_counter == objects.count{
        //                    block(1)
        //                    delay(0.5, closure: {
        //                        completion()
        //                    })
        //                }
        //            })
        //        }
    }
}

extension Inspection {
    
    @objc func deleteAllData(){
        //        guard let id = id else{
        //            return
        //        }
        //        PFObservation.load(for: id) { (observations) in
        //            for observation in observations ?? []{
        //                observation.unpinInBackground()
        //                guard let observationId = observation.id else{
        //                    continue
        //                }
        //                PFPhoto.load(for: observationId, result: { (photos) in
        //                    for photo in photos ?? []{
        //                        photo.unpinInBackground()
        //                        guard let photoId = photo.id else{
        //                            continue
        //                        }
        //                        let path = FileManager.directory.appendingPathComponent(photoId)
        //                        try? FileManager.default.removeItem(at: path)
        //                    }
        //                    PFPhotoThumb.load(for: observationId, result: { (thumbs) in
        //                        for thumb in thumbs ?? []{
        //                            thumb.unpinInBackground()
        //                            guard let photoId = thumb.id else{
        //                                continue
        //                            }
        //                            let path = FileManager.directory.appendingPathComponent(photoId)
        //                            try? FileManager.default.removeItem(at: path)
        //                        }
        //                    })
        //                })
        //            }
        //        }
    }
}

extension Inspection {
    @objc static func loadAndPin(completion: @escaping ()->()){
        //        let query = PFInspection.query()
        //        query!.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        //        query!.findObjectsInBackground(block: { (inspections, error) in
        //            for case let inspection as PFInspection in inspections ?? []{
        //                guard let id = inspection.id else {
        //                    continue
        //                }
        //                try? inspection.pin()
        //                let observationQuery = PFObservation.query()
        //                observationQuery?.whereKey("inspectionId", equalTo: id)
        //                observationQuery?.findObjectsInBackground(block: { (observations, error) in
        //                    for case let observation as PFObservation in observations ?? [] {
        //                        guard let observationId = observation.id else{
        //                            continue
        //                        }
        //                        try? observation.pin()
        //                        let photoQuery = PFPhoto.query()
        //                        photoQuery?.whereKey("observationId", equalTo: observationId)
        //                        photoQuery?.findObjectsInBackground(block: { (photos, error) in
        //                            for case let photo as PFPhoto in photos ?? []{
        //                                try? photo.pin()
        //                                photo.file?.getDataInBackground(block: { (data, error) in
        //                                    if let data = data{
        //                                        try? data.write(to: FileManager.directory.appendingPathComponent(photo.id!, isDirectory: true))
        //                                    }
        //                                })
        //                            }
        //                        })
        //                    }
        //                })
        //
        //            }
        //            completion()
        //        })
    }
}
