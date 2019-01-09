//
//  PFInspection.swift
//  EAO
//
//  Created by Micha Volin on 2017-04-26.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import Parse
import RealmSwift

enum PFInspectionError: Error{
    case zeroObservations
    case someObjectsFailed(Int)
    case inspectionIdNotFound
    case fail
    case noConnection
    
    var message: String{
        switch self {
        case .zeroObservations :
            return "There are no observation elements in this inspection"
        case .someObjectsFailed(let number) :
            return "Error: \(number) element(s) failed to upload to the server.\nDon't worry - your elements are still saved locally in your phone and you can view them in the 'In Progress' tab."
        case .inspectionIdNotFound :
            return "Error occured whle uploading, please try again later"
        case .fail :
            return "Failed to Upload Inspection, please try again later"
        case .noConnection:
            return "It seems that you don't have an active internet connection. Please try uploading data again when you have cellular data or Wi-Fi connection"
        }
    }
}

//MARK: -
final class PFInspection: PFObject, PFSubclassing {
    internal var progress: Float = 0
    internal var isBeingUploaded = false
    internal var isStoredLocally: Bool {
        get {
            guard let id = self.id, let realm = try? Realm(), let inspection = realm.objects(InspectionMeta.self).filter("localId == %@", id).first else {
                return false
            }
            
            return inspection.isStoredLocally
        }
        set (value) {
            guard let id = self.id, let realm = try? Realm(), let inspection = realm.objects(InspectionMeta.self).filter("localId == %@", id).first else {
                return
            }
            
            try? realm.write {
                inspection.isStoredLocally = value
            }
        }
    }
    internal var failed = [PFObject]()
    
    //MARK: -
    
    @NSManaged var id : String?
    @NSManaged var userId : String?
    @NSManaged var isSubmitted  : NSNumber?
    @NSManaged var project  : String?
    @NSManaged var title    : String?
    @NSManaged var subtitle : String?
    @NSManaged var subtext  : String?
    @NSManaged var number    : String?
    @NSManaged var start    : Date?
    @NSManaged var end        : Date?
    @NSManaged var teamID   : String?
    @NSManaged var observation: [PFObservation]
    
    static func parseClassName() -> String {
        return "Inspection"
    }
    
    //MARK: - Submission
    func submit(completion: @escaping (_ success: Bool,_ error: PFInspectionError?)->Void, block: @escaping (_ progress : Float)->Void){
        var objects = [PFObject]()
        self.failed.removeAll()
        if !Reachability.isConnectedToNetwork(){
            block(0)
            completion(false, .noConnection)
            return
        }
        guard let id = self.id else{
            block(0)
            completion(false, .inspectionIdNotFound)
            return
        }
        block(0)
        PFObservation.load(for: id) { (observations) in
            guard let observations = observations, !observations.isEmpty else{
                block(0)
                completion(false, .zeroObservations)
                return
            }
            var counter = 0
            objects.append(contentsOf: observations as [PFObject])
            objects.insert(self as PFObject, at: 0)
            for observation in observations{
                guard let observationId = observation.id else{
                    self.failed.append(observation)
                    //also all the photos
                    counter += 1
                    if counter == observations.count{
                        self.save(objects: objects, completion: {
                            var success = true
                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
                            if self.failed.count == objects.count{
                                _error = PFInspectionError.fail
                                success = false
                            } else if self.failed.isEmpty{
                                _error = nil
                            }
                            if !self.failed.isEmpty{
                                success = false
                            }
                            completion(success, _error)
                        }, block: { (progress) in
                            block(progress)
                        })
                    }
                    continue
                }
                PFPhoto.load(for: observationId, result: { (photos) in
                    if let photos = photos{
                        photos.setPFFiles()
                        objects.append(contentsOf: photos as [PFObject])
                    }
                    counter += 1
                    if counter == observations.count{
                        self.save(objects: objects, completion: {
                            var success = true
                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
                            if self.failed.count == objects.count{
                                _error = PFInspectionError.fail
                                success = false
                            } else if self.failed.isEmpty{
                                _error = nil
                            }
                            if !self.failed.isEmpty{
                                success = false
                            }
                            completion(success, _error)
                        }, block: { (progress) in
                            block(progress)
                        })
                    }
                })
                PFAudio.load(for: observationId, result: { (audios) in
                    if let audios = audios {
                        audios.setPFFiles()
                        objects.append(contentsOf: audios as [PFObject])
                    }
                    counter += 1
                    if counter == observations.count{
                        self.save(objects: objects, completion: {
                            var success = true
                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
                            if self.failed.count == objects.count{
                                _error = PFInspectionError.fail
                                success = false
                            } else if self.failed.isEmpty{
                                _error = nil
                            }
                            if !self.failed.isEmpty{
                                success = false
                            }
                            completion(success, _error)
                        }, block: { (progress) in
                            block(progress)
                        })
                    }
                })
                
                PFVideo.load(for: observationId, result: { (videos) in
                    if let videos = videos {
                        videos.setPFFiles()
                        objects.append(contentsOf: videos as [PFObject])
                    }
                    counter += 1
                    if counter == observations.count{
                        self.save(objects: objects, completion: {
                            var success = true
                            var _error: PFInspectionError? = .someObjectsFailed(self.failed.count)
                            if self.failed.count == objects.count{
                                _error = PFInspectionError.fail
                                success = false
                            } else if self.failed.isEmpty{
                                _error = nil
                            }
                            if !self.failed.isEmpty{
                                success = false
                            }
                            completion(success, _error)
                        }, block: { (progress) in
                            block(progress)
                        })
                    }
                })
            }
        }
    }
    
    fileprivate func save(objects: [PFObject], completion: @escaping ()->Void, block: @escaping (_ progress : Float)->Void){
        var object_counter = 0
        for object in objects{
            
            (object as? PFInspection)?.isSubmitted = true
            object.saveInBackground(block: { (success, error) in
                if success && error == nil{
                    
                } else{
                    self.failed.append(object)
                    self.isSubmitted = false
                    try? self.pin()
                }
                object_counter += 1
                block(Float(object_counter)/Float(objects.count))
                if object_counter == objects.count{
                    block(1)
                    delay(0.5, closure: {
                        completion()
                    })
                }
            })
        }
    }
}

extension PFInspection {
    @objc func deleteAllData(){
        guard let id = id else{
            return
        }
        PFObservation.load(for: id) { (observations) in
            for observation in observations ?? []{
                observation.unpinInBackground()
                guard let observationId = observation.id else{
                    continue
                }
                PFPhoto.load(for: observationId, result: { (photos) in
                    for photo in photos ?? []{
                        photo.unpinInBackground()
                        guard let photoId = photo.id else{
                            continue
                        }
                        let path = FileManager.directory.appendingPathComponent(photoId)
                        try? FileManager.default.removeItem(at: path)
                    }
                    PFPhotoThumb.load(for: observationId, result: { (thumbs) in
                        for thumb in thumbs ?? []{
                            thumb.unpinInBackground()
                            guard let photoId = thumb.id else{
                                continue
                            }
                            let path = FileManager.directory.appendingPathComponent(photoId)
                            try? FileManager.default.removeItem(at: path)
                        }
                    })
                })
            }
        }
    }
}

extension PFInspection {

    /**
     Sync list of all user's inspections to the local Realm database
     Inspection details are not synced
     */
    static func fetchInspectionsOnly(completion: @escaping ()->()){
        
        _ = DataServices.shared.deleteAllSubmittedInspections()
        guard  let query = PFInspection.query(),
            let userID = PFUser.current()?.objectId else {
                DispatchQueue.main.async {
                    completion()
                }
                return
        }

        query.whereKey("userId", equalTo: userID)
        query.findObjectsInBackground(block: { (inspections, error) in
            
            for inspection in inspections as? [PFInspection] ?? [] {
                guard let _ = inspection.id else {
                    continue
                }
                let _ = DataServices.add(inspection: inspection)
            }
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
}

/**
 Gets photo data from local file, converts it to PFFileObject, and sets each element's file to corresponding PFFile
 */
extension Array where Element == PFPhoto{
    fileprivate func setPFFiles(){
        self.forEach({ (photo) in
            if let data = photo.get(){
                photo.file = PFFileObject(data: data)
            }
        })
    }
}

/**
Gets photo data from local file, converts it to PFFileObject, and sets each element's file to corresponding PFFile
 */
extension Array where Element == PFVideo{
    
    fileprivate func setPFFiles(){
        self.forEach({ (video) in
            if let data = video.get(){
                video.file = PFFileObject(data: data)
            }
        })
    }
}

/**
 Gets autdio data from local file, converts it to PFFileObject, and sets each element's file to corresponding PFFile
 */
extension Array where Element == PFAudio{
    fileprivate func setPFFiles(){
        self.forEach({ (audio) in
            if let data = audio.get(){
                audio.file = PFFileObject(data: data)
            }
        })
    }
}


