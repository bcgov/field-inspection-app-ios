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

extension DataServices {
    
    /**
     Create Photo and PhotoThumb, don't save them to Realm yet,
     */
    class func preparePhoto(image: UIImage, index: Int, location: CLLocation?, observationID: String, description: String?) -> (PhotoThumb, Photo)? {
        
        guard let dataPhoto: Data = image.jpegData(compressionQuality: Constants.jpegNoCompression) else {
            return nil
        }
        guard let dataThumb: Data = UIImage.resizeImage(image: image).jpegData(compressionQuality: Constants.jpegCompression) else {
            return nil
        }
        
        let photo = Photo()
        photo.caption = description
        photo.observationId = observationID
        photo.index = index
        photo.coordinate = RealmLocation(location: location)
        
        let photoThumb = PhotoThumb()
        photoThumb.observationId = observationID
        photoThumb.originalType = "photo"
        photoThumb.index = index

        do {
            try dataPhoto.write(to: FileManager.workDirectory.appendingPathComponent(photo.id, isDirectory: false))
            try dataThumb.write(to: FileManager.workDirectory.appendingPathComponent(photoThumb.id, isDirectory: false))
        } catch let error {
            print("\(#function) \(error)")
            return nil
        }
        
        return (photoThumb, photo)
    }
    
    class func savePhoto(image: UIImage, index: Int, location: CLLocation?, observationID: String, description: String?) -> Bool {
        
        if let _ = DataServices.saveThumbnail(image: image, index: index, originalType: "photo", observationID: observationID, description: description),
            let _ = DataServices.saveFull(image: image, index: index, location: location, observationID: observationID, description: description) {
            return true
        }
        return false
    }
    
    internal class func saveFull(image: UIImage, index: Int, location: CLLocation?, observationID: String, description: String?) -> String? {
        
        guard let data: Data = UIImage.resizeImage(image: image).jpegData(compressionQuality: Constants.jpegCompression) else {
            return nil
        }
        print("Image full size of \(index) is \(data.count)")

        let photo = Photo()
        photo.caption = description
        photo.observationId = observationID
        photo.index = index
        photo.coordinate = RealmLocation(location: location)
        
        do {
            let realm = try Realm()
            try data.write(to: FileManager.workDirectory.appendingPathComponent(photo.id, isDirectory: true))
            try realm.write {
                realm.add(photo, update: true)
            }
            return photo.id
        } catch let error {
            print("Realm or Data save exception \(error.localizedDescription)")
            return nil
        }
    }
    
    internal class func saveThumbnail(image: UIImage, index: Int, originalType: String, observationID: String, description: String?) -> String? {
        
        guard let data: Data = UIImage.resizeImage(image: image).jpegData(compressionQuality: Constants.jpegCompression) else {
            return nil
        }
        print("thumb size of \(index) is \(data.count)")
        
        let photo = PhotoThumb()
        photo.observationId = observationID
        photo.originalType = originalType
        photo.index = index
        
        do {
            let realm = try Realm()
            try data.write(to: FileManager.workDirectory.appendingPathComponent(photo.id, isDirectory: true))
            
            try realm.write {
                realm.add(photo, update: true)
            }
            return photo.id
        } catch let error {
            print("Realm or Data save exception \(error.localizedDescription)")
            return nil
        }
    }
    
    internal class func getThumbnailFor(observationID: String, at index: Int, completion: @escaping (_ success: Bool, _ photos: PhotoThumb? ) -> Void) {
        
        DataServices.getThumbnailsFor(observationID: observationID) { (result, thumbnails) in
            if result == true, (thumbnails?.count ?? 0) > 0 {
                let theThumbnail = thumbnails?.filter({ $0.index == index }).first
                return completion(false, theThumbnail)
            } else {
                return completion(false, nil)
            }
        }
    }
    
    internal class func getPhoto(for observationID: String, at index: Int) -> Photo? {

        let photos = DataServices.getPhotos(for: observationID)
        if photos.count > 0 {
            let photo = photos.filter({ $0.index == index }).first
            return photo
        }
        return nil
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
    
    internal class func getPhotos(for observationId: String) -> [Photo] {
        
        do {
            let realm = try Realm()
            let results = realm.objects(Photo.self).filter("observationId in %@", [observationId])
            let resultsArray = Array(results)
            
            print("\(#function): count = \(results.count)");
            return resultsArray
        } catch let error {
            print("\(#function): \(error.localizedDescription)");
            return []
        }
    }
    
    internal class func getPhotoAt(observationID: String, at: Int, completion: @escaping (_ success: Bool, _ photos: Photo? ) -> Void) {
        
        let photos = getPhotos(for: observationID)
        if photos.count >= at {
            return completion(true, photos[at])
        } else {
            return completion(false, nil)
        }
    }
}
