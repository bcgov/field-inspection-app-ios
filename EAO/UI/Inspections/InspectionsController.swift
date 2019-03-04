//
// EAO
//
// Copyright © 2017 Province of British Columbia
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Micha Volin on 2017-03-30.
//

import MapKit
import CoreLocation
import Parse

final class InspectionsController: UIViewController, CLLocationManagerDelegate {
    
    enum Sections: Int {
        case Draft = 0
        case Submitted
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addNewInspectionButton: UIButton!
    @IBOutlet private var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    // MARK: variables
    private var isBeingUploaded = false
    private var locationManager: CLLocationManager = {
        // TODO:(jl) This should be moved to where its used and the user advised
        // why we're going to as for it.
        let lm = CLLocationManager()
        lm.requestWhenInUseAuthorization()
        
        return lm
    }()
    
    private var data = [Inspection]()
    private var selectedInspectionIndexPath: IndexPath?
    private static let inspectionFormControllerSegueID = "InspectionFormControllerSegueID"
    private static let inspectionSetupControllerSegueID = "InspectionSetupControllerSegueID"
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(InspectionsController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = Theme.governmentDeepYellow
        
        return refreshControl
    }()
    
    internal static var reference: InspectionsController? {
        return (AppDelegate.root?.presentedViewController as? UINavigationController)?.viewControllers.first as? InspectionsController
    }
    
    internal var inspections = (draft: [Inspection](), submitted: [Inspection]())
    
    // MARK: -
    private var selectedIndex: Int {
        return segmentedControl.selectedSegmentIndex
    }
    
    // MARK: -
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        commonInit()
        locationManager.delegate = self
        addObserver(#selector(insertByDate(_ :)), .insertByDate)
        addObserver(#selector(reload), .reload)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        loadInspections()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == InspectionsController.inspectionFormControllerSegueID {
            let inspeciton = data[selectedInspectionIndexPath!.row]
            let dvc = segue.destination as! InspectionFormController
            dvc.inspection = inspeciton
        }
    }
    
    private func commonInit() {
        
        addNewInspectionButton.layer.cornerRadius = 5
        addNewInspectionButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addNewInspectionButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        addNewInspectionButton.layer.shadowOpacity = 0.7
        addNewInspectionButton.layer.shadowRadius = 4
        
        tableView.contentInset.bottom = 10
    }
    
    // MARK: - IB Actions
    @IBAction func addInspectionTapped(_ sender: UIButton) {
        
        sender.isEnabled = false
        performSegue(withIdentifier: InspectionsController.inspectionSetupControllerSegueID, sender: nil)
        sender.isEnabled = true
    }
    
    @IBAction func editTapped(_ sender: UIButton, forEvent event: UIEvent) {
        
        guard let indexPath = tableView.indexPath(for: event) else {
            return
        }
        
        selectedInspectionIndexPath = indexPath
        performSegue(withIdentifier: InspectionsController.inspectionFormControllerSegueID, sender: nil)
    }
    
    @IBAction func segmentedControlChangedValue(_ sender: UISegmentedControl) {
        
        if selectedIndex == Sections.Submitted.rawValue {
            tableView.addSubview(refreshControl)
        } else {
            refreshControl.removeFromSuperview()
        }
        
        updateDataForSelectedIndex();
        
        addNewInspectionButton.isHidden = selectedIndex == 0 ? false : true
        tableViewBottomConstraint.constant = selectedIndex == 0 ? 10 : -60
        
        tableView.reloadData()
    }
    
    // MARK: -
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        if selectedIndex == Sections.Submitted.rawValue {
            
            guard NetworkManager.shared.isReachable else {
                let title = "Network Required"
                let message = "You must be connected to a WiFi or celular network to fetch updates"
                
                self.showAlert(withTitle: title, message: message) {
                    self.loadInspections(fetchRemote: false)
                    refreshControl.endRefreshing()
                }
                return
            }
            
            loadInspections(fetchRemote: true)
        }
        refreshControl.endRefreshing()
    }
    
    private func loadInspections(fetchRemote: Bool = false) {
        
        indicator.startAnimating()
        
        //        if fetchRemote == true {
        //            PFInspection.fetchInspectionsOnly {
        //                self.indicator.stopAnimating()
        //                self.loadInspections(fetchRemote: false)
        //            }
        //        } else {
        let results = DataServices.shared.fetchInspections()
        self.inspections.draft = results.filter { $0.isSubmitted == false }
        self.inspections.submitted = results.filter { $0.isSubmitted == true }
        self.sort()
        self.updateDataForSelectedIndex()
        
        self.indicator.stopAnimating()
        self.tableView.reloadData()
        //        }
    }
    
    // Use this method to insert an inspection to the 'In Progress' tab
    @objc dynamic public func insertByDate(_ notification: Notification?) {
        
        if let inspection = notification?.object as? Inspection {
            self.inspections.draft.append(inspection);
            self.inspections.draft.sort(by: { (left, right) -> Bool in
                guard let startL = left.start, let startR = right.start else {
                    return false
                }
                return startL > startR
            })
            
            updateDataForSelectedIndex()
            self.tableView.reloadData()
        }
    }
    
    @objc dynamic private func reload() {
        
        loadInspections()
    }
    
    // Use this method to put an inspection from 'In Progress' to 'Submitted'
    private func moveToSubmitted(inspection: Inspection?) {
        
        guard let inspection = inspection, let idx = inspections.draft.index(of: inspection)  else {
            return
        }
        
        inspections.draft.remove(at: idx)
        inspections.submitted.insert(inspection, at: 0)
        
        sort()
        updateDataForSelectedIndex()
        tableView.reloadData()
    }
    
    private func updateDataForSelectedIndex() {
        
        switch selectedIndex {
            
        case Sections.Draft.rawValue:
            self.data = self.inspections.draft
            print("updateDataForSelectedIndex: Draft:\(self.data.count)")
            
        case Sections.Submitted.rawValue:
            self.data = self.inspections.submitted
            print("updateDataForSelectedIndex: Submitted:\(self.data.count)")
            
        default:
            self.data = []
        }
    }
    
    private func configureCell(cell: InspectionCell, atIndexPath indexPath: IndexPath) {
        
        let inspection = data[indexPath.row]
        print("[inspection] \(inspection.debugDescription)")
        
        cell.configureCell(with: inspection)
        
        if inspection.isSubmitted == false {
            cell.enableEdit(canEdit: true)
            cell.configForTransferState(state: .upload)
            cell.onTransferTouched = uploadTouchedCallback(inspection: inspection)
        } else if inspection.isSubmitted && inspection.isStoredLocally {
            cell.configForTransferState(state: .disabled)
            cell.enableEdit(canEdit: false)
        } else if inspection.isSubmitted && inspection.isStoredLocally == false {
            cell.configForTransferState(state: .download)
            cell.onTransferTouched = downloadTouchedCallback(inspection: inspection, cell: cell)
        } else {
            cell.configForTransferState(state: .upload)
            cell.enableEdit(canEdit: !inspection.isSubmitted)
        }
    }
    
    private func checkUploadStatus(inspection: Inspection) -> Bool {
        
        if let observations = DataServices.fetchObservations(for: inspection) {
            
            if observations.count > 0 {
                return true
            } else {
                let title = "No Observations"
                let message = "This inspeciton does not have any observations; there is nothing to upload"
                self.showAlert(withTitle: title, message: message)
                return false
            }
        }
        return false
    }
    
    private func confirmUploadWithUser(completion: @escaping (_ action: UIAlertAction) -> Void) {
        
        let title = "Upload"
        let message = "Do you want to upload this inspection? You won't be able to edit it later"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: completion)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: completion)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        presentAlert(controller: alert)
    }
    
    private func downloadTouchedCallback(inspection: Inspection, cell: InspectionCell) -> (() -> Void) {
        
        return {
            
            if NetworkManager.shared.isReachableOnEthernetOrWiFi == false {
                let title = "WiFi Required"
                let message = "You must be connected to a WiFi network to download an inspection"
                
                self.showAlert(withTitle: title, message: message)
                return
            }
            
            cell.uploadInProgress(isUploading: true)
            DataServices.shared.fetchFullInspection(inspection: inspection) {
                cell.uploadInProgress(isUploading: false)
                if let indexPath = self.tableView.indexPath(for: cell) {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    private func uploadTouchedCallback(inspection: Inspection) -> (() -> Void) {
        
        //TODO:
        // check if there are any attachments to observation
        // if there are no attachments - only notes, allow to upload using cell connection only
        
        return {
            
            if NetworkManager.shared.isReachableOnEthernetOrWiFi == false {
                let title = "WiFi Required"
                let message = "You must be connected to a WiFi network to upload inspections"
                
                self.showAlert(withTitle: title, message: message)
                return
            }
            
            if self.checkUploadStatus(inspection: inspection) {
                self.confirmUploadWithUser(completion: { (action: UIAlertAction) in
                    if action.style == .cancel {
                        return
                    }
                    self.upload(inspection: inspection)
                })
            } else {
                return
            }
        }
    }
    
    private func upload(inspection: Inspection) {
        
        self.indicator.alpha = 1
        self.indicator.startAnimating()
        self.navigationController?.view.isUserInteractionEnabled = false
        self.isBeingUploaded = true
        
        DataServices.shared.upload(inspection: inspection) { (done) in
            self.indicator.stopAnimating()
            self.navigationController?.view.isUserInteractionEnabled = true
            self.isBeingUploaded = false
            self.indicator.alpha = 0
            self.loadInspections()
            self.moveToSubmitted(inspection: inspection)
        }
    }
    
    // MARK: Helpers
    private func sort() {
        
        inspections.draft.sort(by: { (left, right) -> Bool in
            guard let startL = left.start, let startR = right.start else {
                return false
            }
            return startL > startR
        })
        
        inspections.submitted.sort(by: { (left, right) -> Bool in
            guard let startL = left.start, let startR = right.start else {
                return false
            }
            return startL > startR
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension InspectionsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(identifier: "InspectionCell") as! InspectionCell
        
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let inspeciton = data[indexPath.row]
        if !inspeciton.isStoredLocally {
            return
        }
        
        selectedInspectionIndexPath = indexPath
        performSegue(withIdentifier: InspectionsController.inspectionFormControllerSegueID, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if selectedIndex == 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let inspection = self.data[indexPath.row]
        if inspection.isStoredLocally == false {
            return []
        }
        self.presentAlert(title: "Resource Persistence", message: "Warning, photos will remain on the local storage of this device. ")
        
        let action = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            DataServices.remove(localInspection: inspection) {
                
                self.data.remove(at: indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
        
        return [action]
    }
}
