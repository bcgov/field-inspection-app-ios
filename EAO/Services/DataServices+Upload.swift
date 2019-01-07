//
//  DataServices+Upload.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-06.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import Foundation
import Parse
import Photos
import RealmSwift

extension DataServices {
    
    func upload(inspection: Inspection, completion: @escaping (_ done: Bool) -> Void) {
        
        let pfInspection = inspection.createPF()
        pfInspection.saveInBackground()
        pfInspection.saveInBackground(block: { (status, error) in
            completion(true)
        })
    }

    /* TODO:
     add operation to:
     - upload observations
     - upload photos, thumbs
     - upload audio
     - upload videos
    */
    
}
