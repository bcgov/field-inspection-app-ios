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

    internal class func getVideos(for observationID: String) -> [Video]? {
        
        do {
            let realm = try Realm()
            let results = realm.objects(Video.self).filter("observationId in %@", [observationID])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return resultsArray
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
        }
        return nil
    }
    
    internal class func getVideo(for observationID: String, at index: Int) -> Video? {
        
        let videos = DataServices.getVideos(for: observationID)
        let video = videos?.filter({ $0.index == index }).first
        return video
    }

    internal class func saveVideo(avAsset: AVAsset, thumbnail: UIImage,index: Int, observationID: String, description: String?, completion: @escaping (_ created: Bool) -> Void) {
        
        if let _ = DataServices.saveThumbnail(image: thumbnail, index: index, originalType: "video", observationID: observationID, description: description) {
            
            // then save video
            let video = Video()
            video.observationId = observationID
            video.index = index
            video.notes = description
            let exportURL: URL = FileManager.workDirectory.appendingPathComponent(video.id, isDirectory: false)
            let exporter = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputFileType = AVFileType.mov
            exporter?.outputURL = exportURL
            
            exporter?.exportAsynchronously(completionHandler: {
                DataServices.saveVideo(video: video, completion: completion)
            })
        }
    }
    
    internal class func saveVideo(video: Video, completion: @escaping (_ created: Bool) -> Void) {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(video, update: true)
            }
            return completion(true)
        } catch let error {
            print("Realm save exception \(error.localizedDescription)")
            return completion(false)
        }
    }
    
}
