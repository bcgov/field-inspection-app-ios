//
//  DataServices+Projects.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-30.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import RealmSwift
import Alamofire
import AlamofireObjectMapper

// MARK: Network Requests
// TODO: move to the network manager
extension DataServices {
    
    typealias FetchProjectListCompleted = (_ error: DataServicesError?) -> Void

    class func fetchProjectList(completion: FetchProjectListCompleted? = nil) {
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.request(Constants.API.projectListURI).responseArray { (response: DataResponse<[EAOProject]>) in
            
            let (response, error) = NetworkManager.processResponse(response)
            
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completion?(DataServicesError.internalError(message: error.localizedDescription))
                }
                return
            }
            
            // save/update all projects in the data base
            if let responseArray = response {
                do {
                    let realm = try Realm()
                    try realm.write {
                        for responseObject in responseArray {
                            realm.add(responseObject, update: true)
                        }
                    }
                    completion?(nil)
                } catch let error as NSError {
                    print(error)
                    DispatchQueue.main.async {
                        completion?(DataServicesError.requestFailed(error: error))
                    }
                }
            }
        }
    }
}

extension DataServices {
    
    func getProjects() -> Results<EAOProject>? {
        
        do {
            let realm = try Realm()
            let projects = realm.objects(EAOProject.self).sorted(byKeyPath: "name", ascending: true)
            return projects
        } catch {
        }
        
        return nil
    }
    
    func getProjectsAsStrings() -> [String] {
        
        guard let projects = getProjects() else {
            return []
        }
        
        var projectStrings = [String]()
        projectStrings = projects.compactMap({ $0.name })
        return projectStrings
    }
}
