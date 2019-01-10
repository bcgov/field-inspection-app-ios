//
//  DataServicesError.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-30.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import Foundation

protocol LocalizedDescriptionError: Error {
    var localizedDescription: String { get }
}

public enum DataServicesError: LocalizedDescriptionError {
    
    case unknownError
    case noNetworkConnectivity
    case internalError(message: String)
    case requestFailed(error: Error)
    
    var localizedDescription: String {
        switch self {
        case .internalError(message: let message):
            return message
        default:
            return "No Error Provided"
        }
    }
}

