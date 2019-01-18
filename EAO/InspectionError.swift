//
//  InspectionError.swift
//  Field Insp
//
//  Created by Evgeny Yagrushkin on 2018-12-15.
//  Copyright © 2018 Goverment BC. All rights reserved.
//

enum InspectionError: Error {
    case zeroObservations
    case someObjectsFailed(Int)
    case inspectionIdNotFound
    case fail
    case noConnection
    
    var message: String {
        switch self {
        case .zeroObservations :
            return "There are no observation elements in this inspection"
        case .someObjectsFailed(let number) :
            return "Error: \(number) element(s) failed to upload to the server.\nDon't worry - your elements are still saved locally in your phone and you can view them in the 'In Progress' tab."
        case .inspectionIdNotFound :
            return "Error occured whle uploading, please try again later"
        case .fail :
            return "Failed to Upload Inspection, please try again later"
        case .noConnection:
            return "It seems that you don't have an active internet connection. Please try uploading data again when you have cellular data or Wi-Fi connection"
        }
    }
}

