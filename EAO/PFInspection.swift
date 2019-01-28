//
//  PFInspection.swift
//  EAO
//
//  Created by Micha Volin on 2017-04-26.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import Parse
import RealmSwift

enum PFInspectionError: Error {
    case zeroObservations
    case someObjectsFailed(Int)
    case inspectionIdNotFound
    case fail
    case noConnection
    
    var message: String {
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

// MARK: -
final class PFInspection: PFObject, PFSubclassing {
    internal var progress: Float = 0
    internal var isBeingUploaded = false

    internal var failed = [PFObject]()
    
    // MARK: -
    @NSManaged var localId: String?
    @NSManaged var userId: String?
    @NSManaged var isSubmitted: NSNumber?
    @NSManaged var isActive: NSNumber?
    @NSManaged var project: String?
    @NSManaged var title: String?
    @NSManaged var subtitle: String?
    @NSManaged var subtext: String?
    @NSManaged var number: String?
    @NSManaged var start: Date?
    @NSManaged var end: Date?
    @NSManaged var teamID: String?
    @NSManaged var observation: [PFObservation]
    @NSManaged var team: PFTeam?

    static func parseClassName() -> String {
        return "Inspection"
    }
}

extension PFInspection {

    /**
     Sync list of all user's inspections to the local Realm database
     Inspection details are not synced
     */
    static func fetchInspectionsOnly(completion: @escaping ()->Void) {
        
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
                guard let _ = inspection.objectId else {
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

