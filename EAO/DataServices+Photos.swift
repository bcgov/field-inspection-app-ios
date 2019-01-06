//
//  DataServices+Photos.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-30.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import RealmSwift
import Alamofire
import AlamofireObjectMapper

extension DataServices{
    
    internal class func savePhoto(image: UIImage, index: Int, location: CLLocation?, observationID: String, description: String?, completion: @escaping (_ created: Bool) -> Void) {
        
        DataServices.saveThumbnail(image: image, index: index, originalType: "photo", observationID: observationID, description: description) { (result) in
            guard result else {
                return completion (false)
            }
            
            DataServices.saveFull(image: image, index: index, location: location, observationID: observationID, description: description) { (success) in
                if !success{ return completion (false)}
                
                return completion(true)
            }
        }
    }
    
    internal class func saveFull(image: UIImage, index: Int, location: CLLocation?, observationID: String, description: String?, completion: @escaping (_ created: Bool) -> Void) {
        
        let photo = Photo()
        photo.caption = description
        photo.observationId = observationID
        photo.index = index
        photo.coordinate = RealmLocation(location: location)
        
        let data = image.toData(quality: .uncompressed)
        print("full size of \(index) is \(data.count)")
        
        do {
            let realm = try Realm()
            try data.write(to: FileManager.directory.appendingPathComponent(photo.id, isDirectory: true))
            try realm.write {
                realm.add(photo, update: true)
            }
            return completion(true)
            
        } catch let error {
            print("Realm or Data save exception \(error.localizedDescription)")
            return completion(false)
        }
    }
    
    internal class func saveThumbnail(image: UIImage, index: Int, originalType: String, observationID: String, description: String?, completion: @escaping (_ created: Bool) -> Void) {
        
        guard let data: Data = UIImage.resizeImage(image: image).jpegData(compressionQuality: 0) else {
            return completion(false)
        }
        print("thumb size of \(index) is \(data.count)")
        
        let photo = PhotoThumb()
        photo.observationId = observationID
        photo.originalType = originalType
        photo.index = index
        
        do {
            let realm = try Realm()
            try data.write(to: FileManager.directory.appendingPathComponent(photo.id, isDirectory: true))
            
            try realm.write {
                realm.add(photo, update: true)
            }
            
            return completion(true)
            
        } catch let error {
            print("Realm or Data save exception \(error.localizedDescription)")
            return completion(false)
        }
        
    }
    
    internal class func getThumbnailFor(observationID: String, at index: Int, completion: @escaping (_ success: Bool, _ photos: PhotoThumb? ) -> Void) {
        
        DataServices.getThumbnailsFor(observationID: observationID) { (result, thumbnails) in
            if result == true, (thumbnails?.count ?? 0) > 0 {
                let theThumbnail = thumbnails?.filter( { $0.index == index } ).first
                return completion(false, theThumbnail)
            } else {
                return completion(false, nil)
            }
        }
    }
    
    internal class func getPhotoFor(observationID: String, at index: Int, completion: @escaping (_ success: Bool, _ photos: Photo? ) -> Void) {
        
        DataServices.getPhotosFor(observationID: observationID) { (result, photos) in
            if result == true, (photos?.count ?? 0) > 0 {
                let thePhoto = photos?.filter( { $0.index == index } ).first
                return completion(false, thePhoto)
            } else {
                return completion(false, nil)
            }
        }
    }
    
    internal class func getThumbnailsFor(observationID: String, completion: @escaping (_ success: Bool, _ photos: [PhotoThumb]? ) -> Void) {
        
        do {
            let realm = try Realm()
            let results = realm.objects(PhotoThumb.self).filter("observationId in %@", [observationID])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return completion(true, resultsArray)
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
            return completion(false, nil)
        }
    }
    
    internal class func getPhotosFor(observationID: String, completion: @escaping (_ success: Bool, _ photos: [Photo]? ) -> Void) {
        
        do {
            let realm = try Realm()
            let results = realm.objects(Photo.self).filter("observationId in %@", [observationID])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return completion(true, resultsArray)
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
            return completion(false, nil)
        }
    }
    
    internal class func getPhotoAt(observationID: String, at: Int, completion: @escaping (_ success: Bool, _ photos: Photo? ) -> Void) {
        getPhotosFor(observationID: observationID) { (found, pfphotos) in
            if found {
                if (pfphotos?.count)! >= at {
                    return completion(true,  pfphotos?[at])
                } else {
                    return completion(false, nil)
                }
            }
        }
    }
    
}
