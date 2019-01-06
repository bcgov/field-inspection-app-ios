//
//  NewObservationElementManager.swift
//  AllMyPics
//
//  Created by Amir Shayegh on 2017-12-21.
//  Copyright © 2017 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class NewObservationElementManager {
//    lazy var newObservationElementVC: NewObservationElementViewController = {
//        let storyboard = UIStoryboard(name: "NewObservationElement", bundle: Bundle.main)
//        return storyboard.instantiateViewController(withIdentifier: "NewObservationElement") as! NewObservationElementViewController
//    }()
    lazy var newObservationElementVC: NewObservationElementFormViewController = {
        let storyboard = UIStoryboard(name: "newObservationElementForm", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "newObservationElementForm") as! NewObservationElementFormViewController
    }()

    func getVC() -> UIViewController {
        return newObservationElementVC
    }

    func getVCFor(inspection: Inspection) -> UIViewController {
        self.newObservationElementVC.observation = nil
        self.newObservationElementVC.inspection = inspection
        return newObservationElementVC
    }

    func getEditVCFor(observation: Observation, inspection: Inspection, isReadOnly: Bool) -> UIViewController {
        self.newObservationElementVC.inspection = inspection
        self.newObservationElementVC.observation = observation
        self.newObservationElementVC.isReadOnly = isReadOnly
        return newObservationElementVC
    }
}
