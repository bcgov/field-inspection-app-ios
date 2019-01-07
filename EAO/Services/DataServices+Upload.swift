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

        //        inspection["isActive"] = true // so it shows up in the EAO admin site
        //        fetchObservationsFor(inspection: inspection, localOnly: true) { (results: [PFObservation]) in
        //            let inspectionId = inspection.id
        //            inspection["id"] = NSNull()
        //            results.forEach({ (observation) in
        //                observation["inspection"] = inspection
//                        observation.saveInBackground(block: { (status, error) in
//                            inspection.id = inspectionId
//                            inspection.isSubmitted = true
//                            inspection.pinInBackground()
//
//                            completion(true)
//                        })
        //            })
        //        }
    }
    
    
    // MARK: -
    
    internal class func uploadInspection2(inspection: Inspection, completion: @escaping (_ done: Bool) -> Void) {
        //        let object = PFObject(className: "Inspection")
        //
        //        let userId = inspection.userId ?? ""
        //        let project = inspection.project ?? ""
        //        let title = inspection.title ?? ""
        //        let subtitle = inspection.subtitle ?? ""
        //        let subtext = inspection.subtext ?? ""
        //        let number = inspection.number ?? ""
        //        let start = inspection.start
        //        let end = inspection.end
        //
        //        object["userId"] = userId
        //        object["project"] = project
        //        object["title"] = title
        //        object["subtitle"] = subtitle
        //        object["subtext"] = subtext
        //        object["number"] = number
        //        object["start"] = start
        //        object["end"] = end
        //        object["uploaded"] = false
        //
        //        object.saveInBackground { (success, error) in
        //            if success {
        //                self.getObservationsFor(inspection: inspection, completion: { (success, observations) in
        //                    if success {
        //                        let temp: [PFObject] = [PFObject]()
        //                        self.recursiveObservationUpload(observations: observations!, inspection: object, objects: temp, completion: { (success, uploadedObjects) in
        //                            if success {
        //                                // get team
        //                                if inspection.teamID != nil && inspection.teamID != "" {
        //                                    let query = PFQuery(className: "Team")
        //                                    query.getObjectInBackground(withId: inspection.teamID!, block: { (teamobject, error) in
        //                                        if let teamobj = teamobject {
        //                                            object["team"] = teamobj
        //                                            object["uploaded"] = true
        //                                            object["isSubmitted"] = true
        //                                            object["isActive"] = true
        //                                            inspection.isSubmitted = true
        //                                            inspection.pinInBackground()
        //                                            object.saveInBackground(block: { (success, error) in
        //                                                if success {
        //                                                    return completion(true)
        //                                                } else {
        //                                                    return completion(false)
        //                                                }
        //                                            })
        //                                        }
        //                                    })
        //                                } else {
        //                                    object["uploaded"] = true
        //                                    object["isSubmitted"] = true
        //                                    object["isActive"] = true
        //                                    inspection.isSubmitted = true
        //                                    inspection.pinInBackground()
        //                                    object.saveInBackground(block: { (success, error) in
        //                                        if success {
        //                                            return completion(true)
        //                                        } else {
        //                                            return completion(false)
        //                                        }
        //                                    })
        //                                }
        //                            } else {
        //                                return completion(false)
        //                            }
        //                        })
        //                    } else {
        //                        return completion(false)
        //                    }
        //                })
        //            } else {
        //                return completion(false)
        //            }
        //        }
    }
    
    internal class func recursiveObservationUpload(observations: [PFObservation], inspection: PFObject, objects: [PFObject], completion: @escaping (_ done: Bool, _ observations: [PFObject]?) -> Void) {
        //        var array = observations
        //        var results = objects
        //        let current = observations.last
        //        array.removeLast()
        //
        //        uploadObserbation(observation: current!, inspection: inspection) { done, object  in
        //            if done {
        //                results.append(object!)
        //                if !array.isEmpty && array.count > 0 {
        //                    self.recursiveObservationUpload(observations: array,inspection: inspection, objects: results, completion: completion)
        //                } else {
        //                    return completion(true, results)
        //                }
        //            } else {
        //                return completion(false, nil)
        //            }
        //        }
    }
    
    internal class func uploadObserbation(observation: PFObservation, inspection: PFObject, completion: @escaping (_ done: Bool, _ observation: PFObject?) -> Void) {
        //        let object = PFObject(className: "Observation")
        //
        //        let title = observation.title
        //        let requirement = observation.requirement ?? ""
        //        let coordinate = observation.coordinate ?? PFGeoPoint()
        //        let observationDescription = observation.observationDescription ?? ""
        //
        //        object["title"] = title
        //        object["requirement"] = requirement
        //        object["coordinate"] = coordinate
        //        object["observationDescription"] = observationDescription
        //        object["inspection"] = inspection
        //
        //        object.saveInBackground { (success, error) in
        //            if success {
        //                self.uploadVideos(for: observation, observObj: object, completion: { (done) in
        //                    if done {
        //                        self.uploadAudios(for: observation,  obsObj: object, completion: { (done) in
        //                            if done {
        //                                self.uploadPhotos(for: observation, obsObj: object, completion: { (done) in
        //                                    if done {
        //                                        return completion(true, object)
        //                                    } else {
        //                                        return completion(false, nil)
        //                                    }
        //                                })
        //                            } else {
        //                                return completion(false, nil)
        //                            }
        //                        })
        //                    } else {
        //                        return completion(false, nil)
        //                    }
        //                })
        //            } else {
        //                return completion(false, nil)
        //            }
        //        }
    }
    
    internal class func getObservationsFor(inspection: Inspection, completion: @escaping (_ done: Bool, _ observations: [PFObservation]?) -> Void) {
        PFObservation.load(for: inspection.id) { (results) in
            guard let observations = results, !observations.isEmpty else{
                return completion(false, nil)
            }
            return completion(true, observations)
        }
    }
    
    // save locally
    
    internal class func uploadVideo(for observation: PFObservation, obsObj: PFObject, at index: Int, completion: @escaping (_ success: Bool, _ pfObject: PFObject? ) -> Void) {
        //        let video = PFObject(className: "Video")
        //
        //        getVideoAt(observationID: observation.id!, at: index) { (found, pfvideo) in
        //            if !found {
        //                print("not found!")
        //            }
        //
        //            let title: String = pfvideo?.title ?? ""
        //            let notes: String  = pfvideo?.notes ?? ""
        //            var vidIndex: Int = -1
        //            if let indx = pfvideo?.index {
        //                vidIndex = indx as! Int
        //            }
        //
        //            let videoData = pfvideo?.get()
        //            if videoData == nil {
        //                return completion(false, nil)
        //
        //            }
        //            let parseVideoFile = PFFile(name: "\(observation.id!)\(index).mp4", data: videoData!)
        //            parseVideoFile?.saveInBackground(block: { (success, error) -> Void in
        //                if success{
        //                    video["title"] = title
        //                    video["notes"] = notes
        //                    video["index"] = vidIndex
        //                    video["video"] = parseVideoFile
        //                    video["observation"] = obsObj
        //                    video.saveInBackground(block: { (success, error) in
        //                        if success  {
        //                            return completion(true, video)
        //                        } else {
        //                            return completion(false, nil)
        //                        }
        //                    })
        //                } else {
        //                    return completion(false, nil)
        //                }
        //            })
        //        }
    }
    
    // count instead of array of videos because i was resuing functions: there is a function to get video at index for observation
    internal class func recursiveVideoUpload(last index: Int,for observation: PFObservation, observObj: PFObject, parseVideoObjects: [PFObject],completion: @escaping (_ done: Bool, _ videos: [PFObject]) -> Void) {
        if index > -1 {
            
            uploadVideo(for: observation, obsObj: observObj, at: index, completion: { (success, videoObjsect) in
                if success {
                    var objects = parseVideoObjects
                    objects.append(videoObjsect!)
                    
                    let nextIndex = index - 1
                    if nextIndex > -1 {
                        self.recursiveVideoUpload(last: nextIndex, for: observation, observObj: observObj, parseVideoObjects: objects, completion: completion)
                    } else {
                        // done
                        completion(true, objects)
                    }
                } else {
                    // fail
                    completion(false, parseVideoObjects)
                }
            })
        } else {
            // done
            completion(true, parseVideoObjects)
        }
    }
    
    internal class func uploadAudio(for observation: Observation,  obsObj: PFObject, at index: Int, completion: @escaping (_ success: Bool, _ pfObject: PFObject? ) -> Void) {
        //        let audio = PFObject(className: "Audio")
        //        getAudiosFor(observationID: observation.id!) { (success, audios) in
        //            if success, let results = audios {
        //                let current = results[index]
        //                let observationId : String = current.observationId ?? ""
        //                let coordinate : PFGeoPoint = current.coordinate ?? PFGeoPoint()
        //                let index: Int = index
        //                let notes: String = current.notes ?? ""
        //                let title: String = current.title ?? ""
        //                let audioData = current.get()
        //                if audioData == nil { return completion(false, nil)}
        //                let parseAudioFile = PFFile(name: "\(observationId)\(index).mp4a", data: audioData!)
        //                parseAudioFile?.saveInBackground(block: { (success, error) -> Void in
        //                    if success {
        //                        audio["coordinate"] = coordinate
        //                        audio["notes"] = notes
        //                        audio["index"] = index
        //                        audio["title"] = title
        //                        audio["audio"] = parseAudioFile
        //                        audio["observation"] = obsObj
        //                        audio.saveInBackground(block: { (success, error) in
        //                            if success  {
        //                                return completion(true, audio)
        //                            } else {
        //                                return completion(false, nil)
        //                            }
        //                        })
        //                    } else {
        //                        return completion(false, nil)
        //                    }
        //                })
        //            }
        //        }
    }
    
    internal class func recursiveAudioUpload(last index: Int,for observation: Observation,  obsObj: PFObject, parseAudioObjects: [PFObject],completion: @escaping (_ done: Bool, _ audios: [PFObject]) -> Void) {
        if index > -1 {
            uploadAudio(for: observation, obsObj: obsObj, at: index, completion: { (success, audioObjsect) in
                if success {
                    var objects = parseAudioObjects
                    objects.append(audioObjsect!)
                    
                    let nextIndex = index - 1
                    if nextIndex > -1 {
                        self.recursiveAudioUpload(last: nextIndex, for: observation, obsObj: obsObj, parseAudioObjects: objects, completion: completion)
                    } else {
                        // done
                        completion(true, objects)
                    }
                } else {
                    // fail
                    completion(false, parseAudioObjects)
                }
            })
        } else {
            // done
            completion(true, parseAudioObjects)
        }
    }
    
    internal class func uploadAudios(for observation: Observation, obsObj: PFObject, completion: @escaping (_ success: Bool) -> Void) {
        getAudiosFor(observationID: observation.id) { (success, pfaudios) in
            //            if success {
            //                if let count = pfaudios?.count {
            ////                    let parseSoundObjects: [PFAudio] = [PFAudio]()
            ////                    self.recursiveAudioUpload(last: (count - 1), for: observation, obsObj: obsObj, parseAudioObjects: parseSoundObjects, completion: { (done, audios) in
            ////                        if done {
            ////                            return completion(true)
            ////                        } else {
            ////                            // couldnt upload
            ////                            return completion(false)
            ////                        }
            ////                    })
            //                } else {
            //                    // couldnt upload
            //                    return completion(false)
            //                }
            //            } else {
            //                // couldnt upload
            //                return completion(false)
            //
            //            }
        }
    }
    
    internal class func uploadVideos(for observation: PFObservation, observObj: PFObject, completion: @escaping (_ success: Bool) -> Void) {
        //        getVideosFor(observationID: observation.id) { (success, pfvideos) in
        //            if success {
        //                if let count = pfvideos?.count {
        //                    let parseVideObjects: [PFObject] = [PFObject]()
        //                    self.recursiveVideoUpload(last: (count - 1), for: observation, observObj: observObj, parseVideoObjects: parseVideObjects, completion: { (done, videos) in
        //                        if done {
        //                            return completion(true)
        //                        } else {
        //                            // fail
        //                            // couldnt upload videos
        //                            return completion(false)
        //                        }
        //                    })
        //                } else {
        //                    // unlikely yo get here
        //                    return completion(false)
        //                }
        //            } else {
        //                // fail.
        //                // could npt find videos
        //                return completion(false)
        //            }
        //        }
    }
    
    //    internal class func uploadPhotos(for observation: Observation, obsObj: PFObject, completion: @escaping (_ success: Bool) -> Void) {
    //        getPhotosFor(observationID: observation.id) { (success, pfphotos) in
    //            if success {
    //                if let count = pfphotos?.count {
    //                    let parsePhotoObjects: [PFObject] = [PFObject]()
    //                    self.recursivePhotoUpload(last: (count - 1), for: observation, obsObj: obsObj, parsePhotoObjects: parsePhotoObjects, completion: { (done, photos) in
    //                        if done {
    //                            return completion(true)
    //                        } else {
    //                            // fail
    //                            return completion(false)
    //                        }
    //                    })
    //                } else {
    //                    return completion(false)
    //                }
    //            } else {
    //                return completion(false)
    //            }
    //        }
    //    }
    
    //    internal class func recursivePhotoUpload(last index: Int,for observation: Observation, obsObj: PFObject, parsePhotoObjects: [PFObject],completion: @escaping (_ done: Bool, _ photos: [PFObject]) -> Void) {
    //        if index > -1 {
    //            uploadPhoto(for: observation, obsObj: obsObj, at: index, completion: { (success, photoObject) in
    //                if success {
    //                    var objects = parsePhotoObjects
    //                    objects.append(photoObject!)
    //
    //                    let nextIndex = index - 1
    //                    if nextIndex > -1 {
    //                        self.recursivePhotoUpload(last: nextIndex, for: observation, obsObj: obsObj, parsePhotoObjects: objects, completion: completion)
    //                    } else {
    //                        // done
    //                        completion(true, objects)
    //                    }
    //                } else {
    //                    completion(false, parsePhotoObjects)
    //                }
    //            })
    //        } else {
    //            // done
    //            completion(true, parsePhotoObjects)
    //        }
    //    }
    
    
    
    //    internal class func uploadPhoto(for observation: Observation, obsObj: PFObject, at index: Int, completion: @escaping (_ success: Bool, _ pfObject: PFObject? ) -> Void) {
    //
    //        let photo = PFObject(className: "Photo")
    //        getPhotoAt(observationID: observation.id!, at: index) { (found, pfphoto) in
    //            if !found {
    //                print("Not found")
    //                return completion(false, nil)
    //            }
    //
    //            let observationId : String = pfphoto?.observationId ?? ""
    //            let caption       : String = pfphoto?.caption ?? ""
    //            let timestamp     : Date?   = pfphoto?.timestamp ?? nil
    //            let coordinate    : PFGeoPoint = pfphoto?.coordinate ?? PFGeoPoint()
    //            //            let index: Int = index
    //            let photoData = pfphoto?.get()
    //            if photoData == nil { return completion(false, nil)}
    //
    //            let parsePhotoFile = PFFile(name: "\(observationId)\(index).jpeg", data: photoData!)
    //            parsePhotoFile?.saveInBackground(block: { (success, error) -> Void in
    //                if success {
    //                    var picIndex = -1
    //                    if let indx =  pfphoto?.index {
    //                        picIndex = indx as! Int
    //                    }
    //                    photo["coordinate"] = coordinate
    //                    photo["caption"] = caption
    //                    photo["index"] = picIndex
    //                    photo["timestamp"] = timestamp
    //                    photo["photo"] = parsePhotoFile
    //                    photo["observation"] = obsObj
    //                    photo.saveInBackground(block: { (success, error) in
    //                        if success  {
    //                            return completion(true, photo)
    //                        } else {
    //                            return completion(false, nil)
    //                        }
    //                    })
    //                } else {
    //                    return completion(false, nil)
    //                }
    //            })
    //        }
    //    }
    
}
