//
//  ParseUploadOperation.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-07.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import Foundation
import RealmSwift

class InspectionUploadOperation : AsyncOperation {
    
    typealias CompletionBlock = (Bool) -> Void
    
    let objectId: String
    var completion: CompletionBlock
    
    init(objectId: String, completion: @escaping CompletionBlock) {
        self.objectId = objectId
        self.completion = completion
    }
    
    override func execute() {
        
        guard let inspection: Inspection = DataServices.fetch(for: objectId) else {
            self.finished()
            return
        }

        let pfInspection = inspection.createParseObject()
        
        pfInspection.saveInBackground(block: { (status, error) in

            var operations = [Operation]()
            let observations: [Observation] = DataServices.fetchArray(for: self.objectId, idFieldName: "inspectionId")
            for anObservation in observations{
                let observationUpload = ObservationUploadOperation(observationId: anObservation.id)
                operations.append(observationUpload)
            }
            DataServices.shared.uploadQueue.addOperations(operations, waitUntilFinished: false)
            self.finished()

            DataServices.shared.uploadQueue.addOperation({
                self.completion(true)
            })
        })
    }
}


class ObservationUploadOperation : AsyncOperation {
    
    let observationId: String
    
    init(observationId: String) {
        self.observationId = observationId
    }
    
    override func execute() {
        
        guard let observation = DataServices.fetchObservation(for: observationId) else {
            self.finished()
            return
        }

        print("+++++\(self) starting \(observationId)")
        let parseObject = observation.createParseObject()
        parseObject.saveInBackground { [weak self] (_, _) in
            guard let strongSelf = self else {
                self?.finished()
                return
            }

            var operations = [Operation]()
            let photos: [Photo] = DataServices.fetchArray(for: strongSelf.observationId)
            for objectId in photos{
                let upload = AttachmentUploadOperation<Photo>(objectId: objectId.id)
                operations.append(upload)
            }
            let photoThumbs: [PhotoThumb] = DataServices.fetchArray(for: strongSelf.observationId)
            for objectId in photoThumbs{
                let upload = AttachmentUploadOperation<PhotoThumb>(objectId: objectId.id)
                operations.append(upload)
            }
            
            let audios: [Audio] = DataServices.fetchArray(for: strongSelf.observationId)
            for objectId in audios{
                let upload = AttachmentUploadOperation<Audio>(objectId: objectId.id)
                operations.append(upload)
            }
            let videos: [Video] = DataServices.fetchArray(for: strongSelf.observationId)
            for objectId in videos{
                let upload = AttachmentUploadOperation<Video>(objectId: objectId.id)
                operations.append(upload)
            }

            DataServices.shared.uploadQueue.addOperations(operations, waitUntilFinished: false)
            print("-----\(strongSelf) finished \(strongSelf.observationId)")
            strongSelf.finished()
        }
    }
}

class AttachmentUploadOperation<T>: AsyncOperation where T: ParseFactory, T: Object {

    let objectId: String
    
    init(objectId: String) {
        self.objectId = objectId
    }
    
    override func execute() {
        
        guard let realmObject: T = DataServices.fetch(for: objectId) else {
            self.finished()
            return
        }
        
        print("+++++\(self) starting \(objectId)")
        let parseObject = realmObject.createParseObject()
        parseObject.saveInBackground { [weak self] (_, _) in
            guard let strongSelf = self else {
                self?.finished()
                return
            }
            
            print("-----\(strongSelf) finished \(strongSelf.objectId)")
            strongSelf.finished()
        }
    }
}
