//
//  TeamSearchViewController.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-04-03.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit

class TeamSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()

    var completion: ((_ done: Bool,_ team: Team?) -> Void)?
    var teams: [Team] = [Team]()

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }

    @IBAction func closeAction(_ sender: Any) {
        self.completion?(false, nil)
    }

    func setup(teams: [Team], completion: @escaping (_ done: Bool,_ team: Team?) -> Void) {
        self.completion = completion
        self.teams = teams
    }

    func selected(team: Team) {
        completion?(true, team)
    }

    func style() {
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(ProjectListController.refreshData), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        registerCell(name: "TeamSearchTableViewCell")
    }
    
    @objc func refreshData() {
        DataServices.getTeams { [weak self] (done, teams) in
            self?.refreshControl.endRefreshing()
            
            guard let teams = teams, done == true else {
                return
            }
            self?.teams = teams
            self?.tableView.reloadData()
        }
    }
    
    func registerCell(name: String) {
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    func getCell(indexPath: IndexPath) -> TeamSearchTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TeamSearchTableViewCell", for: indexPath) as! TeamSearchTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        cell.setup(team: teams[indexPath.row])
        return cell
    }
}
