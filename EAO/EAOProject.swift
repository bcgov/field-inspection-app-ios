//
//  BaseClass.swift
//
//  Created by Evgeny Yagrushkin on 2018-12-19
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public final class EAOProject: Mappable {

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
  public var name: String?
  public var memPermitID: String?
  public var currentPhase: CurrentPhase?
  public var descriptionValue: String?
  public var type: String?
  public var lat: Float?
  public var openCommentPeriod: String?
  public var eacDecision: String?
  public var status: String?
  public var id: String?
  public var code: String?
  public var region: String?
  public var lon: Float?
  public var proponent: Proponent?
  public var decisionDate: String?

  // MARK: ObjectMapper Initializers
  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public required init?(map: Map){

  }

  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public func mapping(map: Map) {
    name <- map[SerializationKeys.name]
    memPermitID <- map[SerializationKeys.memPermitID]
    currentPhase <- map[SerializationKeys.currentPhase]
    descriptionValue <- map[SerializationKeys.descriptionValue]
    type <- map[SerializationKeys.type]
    lat <- map[SerializationKeys.lat]
    openCommentPeriod <- map[SerializationKeys.openCommentPeriod]
    eacDecision <- map[SerializationKeys.eacDecision]
    status <- map[SerializationKeys.status]
    id <- map[SerializationKeys.id]
    code <- map[SerializationKeys.code]
    region <- map[SerializationKeys.region]
    lon <- map[SerializationKeys.lon]
    proponent <- map[SerializationKeys.proponent]
    decisionDate <- map[SerializationKeys.decisionDate]
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = memPermitID { dictionary[SerializationKeys.memPermitID] = value }
    if let value = currentPhase { dictionary[SerializationKeys.currentPhase] = value.dictionaryRepresentation() }
    if let value = descriptionValue { dictionary[SerializationKeys.descriptionValue] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = lat { dictionary[SerializationKeys.lat] = value }
    if let value = openCommentPeriod { dictionary[SerializationKeys.openCommentPeriod] = value }
    if let value = eacDecision { dictionary[SerializationKeys.eacDecision] = value }
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = code { dictionary[SerializationKeys.code] = value }
    if let value = region { dictionary[SerializationKeys.region] = value }
    if let value = lon { dictionary[SerializationKeys.lon] = value }
    if let value = proponent { dictionary[SerializationKeys.proponent] = value.dictionaryRepresentation() }
    if let value = decisionDate { dictionary[SerializationKeys.decisionDate] = value }
    return dictionary
  }

}
