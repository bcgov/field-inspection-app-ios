//
//  DataServices+Audio.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-30.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import RealmSwift
import Alamofire
import AlamofireObjectMapper

extension DataServices {
    
    internal class func saveAudio(audioURL: URL, index: Int, observationID: String, inspectionID: String, notes: String, title: String, completion: @escaping (_ created: Bool) -> Void) {
        
        let audio = Audio()
        audio.observationId = observationID
        audio.index = index
        audio.notes = notes
        audio.title = title
        let data = NSData(contentsOf: audioURL)
        
        do {
            let realm = try Realm()
            try data?.write(to: FileManager.workDirectory.appendingPathComponent(audio.id, isDirectory: true))
            try realm.write {
                realm.add(audio, update: true)
            }

            return completion(true)
        } catch let error {
            print("Realm or Data save exception \(error.localizedDescription)")
            return completion(false)
        }
    }
    
    internal class func getAudiosFor(observationID: String, completion: @escaping (_ success: Bool, _ audios: [Audio]? ) -> Void) {
        
        do {
            let realm = try Realm()
            let results = realm.objects(Audio.self).filter("observationId in %@", [observationID])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return completion(true, resultsArray)
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
            return completion(false, nil)
        }
    }
    
    internal class func getAudioFor(observationID: String, at index: Int, completion: @escaping (_ success: Bool, _ audio: Audio? ) -> Void) {
        
        DataServices.getAudiosFor(observationID: observationID) { (result, photos) in
            if result == true, (photos?.count ?? 0) > 0 {
                let thePhoto = photos?.filter({ $0.index == index }).first
                return completion(false, thePhoto)
            } else {
                return completion(false, nil)
            }
        }
    }
}
