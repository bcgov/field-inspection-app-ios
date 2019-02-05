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
    
    static let shared = DataServices()
    static let realmFileName = "default.realm"
    static let realmPath: URL = {
        // no backups, put it in the .cachesDirectory
        var workspaceURL = URL(fileURLWithPath: FileManager.workDirectory.path, isDirectory: true)
        return URL(fileURLWithPath: realmFileName, isDirectory: false, relativeTo: workspaceURL)
    }()
    
    

    let uploadQueue: OperationQueue = OperationQueue()

    var teams = [Team]()
    
    // MARK: Realm
    internal class func setup() {
        
        DataServices.configureRealm()
    }
    
    private class func configureRealm() {
        
        let config = Realm.Configuration(fileURL: DataServices.realmPath,
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
    
    internal func fetchInspections() -> [Inspection] {
        //TODO: #11
        guard let userID = PFUser.current()?.objectId else {
            return []
        }
        
        do {
            let realm = try Realm()
            let inspections = realm.objects(Inspection.self).filter("userId in %@", [userID]).sorted(byKeyPath: "title", ascending: true)
            let inspectionsArray = Array(inspections)
            
            print("\(#function): count = \(inspections.count)");
            return inspectionsArray
        } catch {
            return []
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

    class func fetch<T>(for id: String) -> T? where T: Object {
        do {
            let realm = try Realm()
            let observation = realm.objects(T.self).filter("id in %@", [id]).first
            
            return observation
        } catch let error {
            print("fetch realm object: \(error.localizedDescription)");
        }
        return nil
    }

    internal class func fetchArray<T>(for id: String, idFieldName: String = "observationId") -> [T] where T: Object {
        
        do {
            let realm = try Realm()
            let results = realm.objects(T.self).filter("\(idFieldName) in %@", [id])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return resultsArray
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
            return []
        }
    }

    class func fetchObservation(for id: String) -> Observation? {
        do {
            let realm = try Realm()
            let observation = realm.objects(Observation.self).filter("id in %@", [id]).first
            
            return observation
        } catch let error {
            print("fetchObservations: \(error.localizedDescription)");
        }
        return nil
    }

    class func fetchPhoto(for id: String) -> Photo? {
        do {
            let realm = try Realm()
            let observation = realm.objects(Photo.self).filter("id in %@", [id]).first
            return observation
        } catch let error {
            print("fetchObservations: \(error.localizedDescription)");
        }
        return nil
    }
    
    internal class func remove(localInspection inspection: Inspection, completion: (() -> Void)? = nil) {
        
        let inspectionId = inspection.id;

        DispatchQueue.global().async {
            guard let realm = try? Realm() else {
                return
            }
            
            do {
                let myInspection = realm.objects(Inspection.self).filter("id = %@", inspectionId).first!
                let observations = realm.objects(Observation.self).filter("inspectionId in %@", [myInspection.id])
                
                for observation in observations {
                    observation.removeLocalAssets()
                    
                    let photoThumbs = realm.objects(PhotoThumb.self).filter("observationId in %@", [observation.id])
                    let photos = realm.objects(Photo.self).filter("observationId in %@", [observation.id])
                    for photo in photos {
                        try realm.write {
                            if let coord = photo.coordinate {
                                realm.delete(coord)
                            }
                        }
                    }
                    
                    let audios = realm.objects(Audio.self).filter("observationId in %@", [observation.id])
                    for audio in audios {
                        try realm.write {
                            if let coord = audio.coordinate {
                                realm.delete(coord)
                            }
                        }
                    }
                    
                    let videos = realm.objects(Video.self).filter("observationId in %@", [observation.id])
                    for video in videos {
                        try realm.write {
                            if let coord = video.coordinate {
                                realm.delete(coord)
                            }
                        }
                    }
                    
                    try realm.write {
                        if let ocoord = observation.coordinate {
                            realm.delete(ocoord)
                        }
                        realm.delete(photoThumbs)
                        realm.delete(photos)
                        realm.delete(audios)
                        realm.delete(videos)
                    }
                }
                
                try realm.write {
                    realm.delete(observations)
                    
                    if let meta = myInspection.meta {
                        realm.delete(meta)
                    }
                    
                    realm.delete(myInspection)
                }
                
                DispatchQueue.main.async {
                    completion?()
                }
                
            } catch let error {
                print("\(#function) Remove error: \(error.localizedDescription)")
            }
        }
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
                let access: [String: Any] = obj["access"] as? [String: Any],
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
    
    internal class func getUserTeams(user: User, completion: @escaping (_ success: Bool,_ teams: [PFTeam]) -> Void) {
        
        guard let query = PFTeam.query() else {
            return completion(false, [])
        }

        var downloadedTeams = [PFTeam]()
        query.whereKey("users", equalTo: user)
        query.findObjectsInBackground { (teams, error) in
            if let foundTeams: [PFTeam] = teams as? [PFTeam] {
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
                for object in downloaded {
                    if let objectId = object.objectId,
                        let name = object.name, let isActive = object.isActive?.boolValue{
                        let team = Team(objectID: objectId, name: name, isActive: isActive)
                        results.append(team)
                    }
                }
                DataServices.shared.teams = results
                return completion(true, results)
            } else {
                guard let query = PFTeam.query() else {
                    return completion(false, [])
                }
                query.fromLocalDatastore()
                query.findObjectsInBackground { (objects, error) in

                    guard objects != nil else {
                        return completion(false, nil)
                    }
                    
                    var results = [Team]()
                    for object in downloaded {
                        if let objectId = object.objectId,
                            let name = object.name, let isActive = object.isActive?.boolValue{
                            let team = Team(objectID: objectId, name: name, isActive: isActive)
                            results.append(team)
                        }
                    }
                    DataServices.shared.teams = results
                    return completion(true, results)
                }
            }
        }
    }
    
    func getTeam(with teamID: String) -> Team? {
        let team = DataServices.shared.teams.filter({ $0.objectID == teamID }).first
        return team
    }
    
    /*
     update important remote data:
     - teams
     - Projects
     - Remote inspections (?)
     */
    func reloadReferenceData(completion: @escaping (_ error: Error?)->Void) {
        
        guard Reachability.isConnectedToNetwork() else {
            completion(DataServicesError.noNetworkConnectivity)
            return
        }
        
        DataServices.getTeams { (sucess, _) in
            DataServices.fetchProjectList() { (error: Error?) in
                completion(error)
            }
        }
    }
}
