//
//  DataServices+Video.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-30.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import RealmSwift
import Alamofire
import AlamofireObjectMapper
import AVFoundation

extension DataServices {

    internal class func getVideosFor(observationID: String, completion: @escaping (_ success: Bool, _ videos: [PFVideo]? ) -> Void) {
        
        do {
            let realm = try Realm()
            let results = realm.objects(PFVideo.self).filter("observationId in %@", [observationID])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return completion(true, resultsArray)
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
            return completion(false, nil)
        }

    }
    
    internal class func getVideoFor(observationID: String, at index: Int, completion: @escaping (_ success: Bool, _ video: PFVideo? ) -> Void) {
        
        DataServices.getVideosFor(observationID: observationID) { (success, results) in
            if success == true, (results?.count ?? 0) > 0 {
                let theOne = results?.filter( { $0.index == index } ).first
                return completion(false, theOne)
            } else {
                return completion(false, nil)
            }
        }
    }

    internal class func saveVideo(avAsset: AVAsset, thumbnail: UIImage,index: Int, observationID: String, description: String?, completion: @escaping (_ created: Bool) -> Void) {
        
        DataServices.saveThumbnail(image: thumbnail, index: index, originalType: "video", observationID: observationID, description: description) { (done) in
            if !done{ return completion (false)}
            // then save video
            
            let video = PFVideo()
            video.observationId = observationID
            video.index = index
            video.notes = description
            let exportURL: URL = FileManager.directory.appendingPathComponent(video.id, isDirectory: true)
            let exporter = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputFileType = AVFileType.mov
            exporter?.outputURL = exportURL
            
            exporter?.exportAsynchronously(completionHandler: {
                DataServices.savePFVideo(video: video, completion: completion)
            })
        }
    }
    
    internal class func savePFVideo(video: PFVideo, completion: @escaping (_ created: Bool) -> Void) {
        
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(video, update: true)
            try realm.commitWrite()
            return completion(true)
            
        } catch let error {
            print("Realm save exception \(error.localizedDescription)")
            return completion(false)
        }
        
    }
    
    internal class func getVideoAt(observationID: String, at: Int, completion: @escaping (_ success: Bool, _ video: PFVideo? ) -> Void) {
        getVideosFor(observationID: observationID) { (found, pfvideos) in
            if found {
                if (pfvideos?.count)! >= at {
                    return completion(true,  pfvideos?[at])
                } else {
                    return completion(false, nil)
                }
            }
        }
    }

    
}
