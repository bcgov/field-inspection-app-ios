//
//  PFManager.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-16.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Foundation
import AVFoundation
import Parse
import Photos
import RealmSwift
import Alamofire
import AlamofireObjectMapper

class DataServices {
    
    static let realmFileName = "default.realm"
    static let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    static let shared = DataServices()

    // MARK: Realm

    internal class func setup() {
        
        DataServices.configureRealm()
    }
    
    private class func configureRealm() {
        
        let config = Realm.Configuration(fileURL: DataServices.realmPath(),
                                         schemaVersion: Settings.REALM_SCHEMA_NUMBER,
                                         migrationBlock: { migration, oldSchemaVersion in
                                            // check oldSchemaVersion here, if we're newer call
                                            // a method(s) specifically designed to migrate to
                                            // the desired schema. ie `self.migrateSchemaV0toV1(migration)`
                                            if (oldSchemaVersion < 1) {
                                                // Nothing to do. Realm will automatically remove and add fields
                                            }
        },
                                         shouldCompactOnLaunch: { totalBytes, usedBytes in
                                            // totalBytes refers to the size of the file on disk in bytes (data + free space)
                                            // usedBytes refers to the number of bytes used by data in the file
                                            
                                            // Compact if the file is over 10MB in size and less than 50% 'used'
                                            let oneHundredMB = 10 * 1024 * 1024
                                            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    // Allow customization of the Realm; this will let us keep it in a location that is not
    // backed up if needed.
    private class func realmPath() -> URL {
        
        var workspaceURL = URL(fileURLWithPath: DataServices.documentsURL.path, isDirectory: true).appendingPathComponent("db")
        var directory: ObjCBool = ObjCBool(false)
        
        if !FileManager.default.fileExists(atPath: workspaceURL.path, isDirectory: &directory) {
            // no backups
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            
            do  {
                try FileManager.default.createDirectory(at: workspaceURL, withIntermediateDirectories: false, attributes: nil)
                try workspaceURL.setResourceValues(resourceValues)
            } catch {
                fatalError("Unable to create a location to store the database")
            }
        }
        
        return URL(fileURLWithPath: realmFileName, isDirectory: false, relativeTo: workspaceURL)
    }

    class func add(inspection: Inspection, isStoredLocally: Bool = false) -> Bool {
        
        guard let userID = PFUser.current()?.objectId else {
            return false
        }
        
        do {
            let realm = try Realm()
            try realm.write {
                
                let doc = InspectionMeta()
                doc.id = UUID().uuidString
                doc.localId = inspection.id
                doc.isStoredLocally = isStoredLocally
                doc.modifiedAt = Date()
                
                inspection.userId = userID
                inspection.meta = doc
                realm.add(inspection, update: true)
            }
            
        } catch {
            print("\(#function) Realm error: \(error.localizedDescription)")
            return false
        }
        return true
    }


    class func add(observation: Observation) -> Bool {
        
        do {
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

    
    internal class func fetchInspections(completion: ((_ results: [Inspection]) -> Void)? = nil) {
        //TODO: #11
        guard let userID = PFUser.current()?.objectId else {
            completion?([])
            return
        }
        
        do {
            let realm = try Realm()
            let inspections = realm.objects(Inspection.self).filter("userId in %@", [userID]).sorted(byKeyPath: "title", ascending: true)
            let inspectionsArray = Array(inspections)
            
            print("fetchInspections: count = \(inspections.count)");
            completion?(inspectionsArray)
        } catch {
            completion?([])
        }
    }
    
    class func fetchObservations(for inspection: Inspection) -> [Observation]? {
        do {
            let realm = try Realm()
            let observations = realm.objects(Observation.self).filter("inspectionId in %@", [inspection.id]).sorted(byKeyPath: "pinnedAt", ascending: true)
            let observationsArray = Array(observations)
            
            print("fetchObservations: count = \(observations.count)");
            return observationsArray
        } catch let error {
            print("fetchObservations: \(error.localizedDescription)");
        }
        return nil
    }
    
    
    internal class func fetchPhotosFor(observation: Observation, completion: ((_ results: [PFPhoto]) -> Void)? = nil) {
        
//        guard let query = PFPhoto.query() else {
//            completion?([])
//            return
//        }
//
//        query.whereKey("observation", equalTo: observation)
//        query.findObjectsInBackground { (objects, error) -> Void in
//            guard let objects = objects as? [PFPhoto], error == nil else {
//                completion?([])
//                return
//            }
//
//            let group = DispatchGroup()
//            for (index, object) in objects.enumerated() {
//                group.enter()
//                object.id = UUID().uuidString // Local ID Only, must be set.
//                object.observationId = observation.id!
//                object.pinInBackground();
//                DataServices.fetchDataFor(photo: object, observation: observation, index: index, completion: { (data: Data?) in
//                    group.leave()
//                })
//            }
//
//            group.notify(queue: .main) {
//                // all photo data fetched
//                completion?(objects)
//            }
//        }
    }
    
    internal class func fetchDataFor(photo: PFPhoto, observation: Observation, index: Int, completion: ((_ result: Data?) -> Void)? = nil) {
        
//        guard let image = photo["photo"] as? PFFile else {
//            completion?(nil)
//            return
//        }
//
//        var loc: CLLocation = CLLocation(latitude: 0, longitude: 0)
//        if let lat = photo.coordinate?.latitude, let lng = photo.coordinate?.longitude {
//            loc = CLLocation(latitude: lat, longitude: lng)
//        }
//
//        if image.isDataAvailable {
//            if let imageData = try? image.getData() {
//                DataServices.savePhoto(image: UIImage(data: imageData)!, index: index, location: loc, observationID: observation.id!, description: photo.caption, completion: { (success) in
//                    completion?(imageData)
//                })
//            }
//
//            return
//        }
//
//        image.getDataInBackground(block: { (data: Data?, err: Error?) in
//            if let imageData = data {
//                DataServices.savePhoto(image: UIImage(data: imageData)!, index: index, location: loc, observationID: observation.id!, description: photo.caption, completion: { (success) in
//                    completion?(imageData)
//                })
//            }
//        })
    }
    
    internal class func deleteLocalObservations(forInspection inspection: Inspection, completion: (() -> Void)? = nil) {
        
//        guard let query = PFObservation.query() else {
//            completion?()
//            return
//        }
//
//        query.whereKey("inspection", equalTo: inspection)
//        query.fromLocalDatastore()
//        query.findObjectsInBackground { (objects, error) -> Void in
//            DispatchQueue.global(qos: .background).async {
//                guard let objects = objects as? [PFObservation], error == nil else {
//                    return
//                }
//
//                objects.forEach({ (observation) in
//                    try? observation.unpin()
//                })
//
//                DispatchQueue.main.async {
//                    inspection.isStoredLocally = false
//                    completion?()
//                }
//            }
//        }
    }
    

    
    
        
    internal class func isUserMobileAccessEnabled(completion: @escaping (_ success: Bool) -> Void) {
        
        guard let user: User = PFUser.current() as? User, let id = user.objectId else {
            return completion(false)
        }

        guard let query: PFQuery = PFUser.query() else {
            return completion(false)
        }

        query.getObjectInBackground(withId: id) { (userObj, error) in
            if let obj = userObj,
                let access: [String: Any] = obj["access"] as? [String : Any],
                let mobileAccess: Bool = access["mobileAccess"] as? Bool,
                let isActive: Bool = obj["isActive"] as? Bool {
                print(access)
                if mobileAccess && isActive {
                    return completion(true)
                } else {
                    return completion(false)
                }
            } else {
                return completion(false)
            }
        }
        
    }
    
    internal class func getUserTeams(user: User, completion: @escaping (_ success: Bool,_ teams: [PFObject]) -> Void) {
        
        let query = PFQuery(className: "Team")
        var downloadedTeams = [PFObject]()
        query.whereKey("users", equalTo: user)
        query.findObjectsInBackground { (teams, error) in
            if let foundTeams: [PFObject] = teams {
                for team in foundTeams {
                    downloadedTeams.append(team)
                    team.pinInBackground()
                }
                return completion(true, downloadedTeams)
            }
            else {
                return completion(false, downloadedTeams)
            }
        }
    }
    
    internal class func getTeams(completion: @escaping (_ success: Bool, _ teams: [Team]?) -> Void) {
        
        guard let user: User = PFUser.current() as? User else {
            print("\(#function) user is missing")
            return completion(false, nil)
        }
        
        self.getUserTeams(user: user) { (done, downloaded)  in
            if done {
                var results = [Team]()
                for object: PFObject in downloaded {
                    results.append(Team(objectID: object.objectId!, name: (object["name"] as? String)!, isActive: (object["isActive"] as? Bool)!))
                }
                return completion(true, results)
            } else {
                let query = PFQuery(className: "Team")
                query.fromLocalDatastore()
                query.findObjectsInBackground { (objects, error) in
                    if objects != nil  {
                        var r = [Team]()
                        for object: PFObject in objects! {
                            r.append(Team(objectID: object.objectId!, name: (object["name"] as? String)!, isActive: (object["isActive"] as? Bool)!))
                        }
                        completion(true, r)
                    } else {
                        return completion(false, nil)
                    }
                }
            }
        }
    }
}


