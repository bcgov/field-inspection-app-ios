//
//  SearchTeam.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import Foundation
class TeamSearch {

    lazy var vc: TeamSearchViewController = {
        return UIStoryboard(name: "Team", bundle: Bundle.main).instantiateViewController(withIdentifier: "TeamSearch") as! TeamSearchViewController
    }()

    func getVC(teams: [Team], callBack: @escaping ((_ close: Bool,_ team: Team?) -> Void )) -> UIViewController {
        vc.setup(teams: teams, completion: callBack)
        return vc
    }

    func display(in container: UIView, on viewController: UIViewController) {
        container.alpha = 1
        viewController.addChildViewController(vc)
        container.addSubview(vc.view)
        vc.view.frame = container.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParentViewController: viewController)
    }

    /**
     Note: also hides container by setting alpha to 0
     */
    func remove(from container: UIView, then hide: Bool? = true) {
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
        if hide! {
            container.alpha = 0
        }
    }
}
