//
//  BaseClass.swift
//
//  Created by Evgeny Yagrushkin on 2018-12-19
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class EAOProject: Object, Mappable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let name = "name"
        static let memPermitID = "memPermitID"
        static let currentPhase = "currentPhase"
        static let descriptionValue = "description"
        static let type = "type"
        static let lat = "lat"
        static let openCommentPeriod = "openCommentPeriod"
        static let eacDecision = "eacDecision"
        static let status = "status"
        static let id = "id"
        static let code = "code"
        static let region = "region"
        static let lon = "lon"
        static let proponent = "proponent"
        static let decisionDate = "decisionDate"
    }
    
    // MARK: Properties
    @objc dynamic var name: String?
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var memPermitID: String?
    @objc dynamic var descriptionValue: String?
    @objc dynamic var type: String?
    @objc dynamic var openCommentPeriod: String?
    @objc dynamic var eacDecision: String?
    @objc dynamic var status: String?
    @objc dynamic var code: String?
    @objc dynamic var region: String?
    @objc dynamic var lat: Float = 0
    @objc dynamic var lon: Float = 0
    @objc dynamic var decisionDate: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    public func mapping(map: Map) {
        name <- map[SerializationKeys.name]
        id <- map[SerializationKeys.id]
        memPermitID <- map[SerializationKeys.memPermitID]
        descriptionValue <- map[SerializationKeys.descriptionValue]
        type <- map[SerializationKeys.type]
        openCommentPeriod <- map[SerializationKeys.openCommentPeriod]
        eacDecision <- map[SerializationKeys.eacDecision]
        status <- map[SerializationKeys.status]
        code <- map[SerializationKeys.code]
        region <- map[SerializationKeys.region]
        lat <- map[SerializationKeys.lat]
        lon <- map[SerializationKeys.lon]
        decisionDate <- map[SerializationKeys.decisionDate]
    }
}

