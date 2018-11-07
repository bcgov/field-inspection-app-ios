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

final class InspectionsController: UIViewController {
    
    enum Sections: Int {
        case Draft = 0
        case Submitted
    }

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addNewInspectionButton: UIButton!
    @IBOutlet private var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var indicator: UIActivityIndicatorView!

	private var isBeingUploaded = false
    private var locationManager: CLLocationManager = {
        // TODO:(jl) This should be moved to where its used and the user advised
        // why we're going to as for it.
        let lm = CLLocationManager()
        lm.requestWhenInUseAuthorization()
        
        return lm
    }()
    private var data = [PFInspection]()
//    private var selectedInspection: PFInspection?
    private var selectedInspectionIndexPath: IndexPath?
    private static let inspectionFormControllerSegueID = "InspectionFormControllerSegueID"
    private static let inspectionSetupControllerSegueID = "InspectionSetupControllerSegueID"
    internal static var reference: InspectionsController? {
        return (AppDelegate.root?.presentedViewController as? UINavigationController)?.viewControllers.first as? InspectionsController
    }
    internal var inspections = (draft: [PFInspection](), submitted: [PFInspection]())

    // MARK: -

    override func viewDidLoad() {

        super.viewDidLoad()
        
        locationManager.delegate = self
        style()
        addObserver(#selector(insertByDate(_ :)), .insertByDate)
        addObserver(#selector(reload), .reload)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tableView.contentInset.bottom = 10

        
        self.load()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == InspectionsController.inspectionFormControllerSegueID {
            let inspeciton = data[selectedInspectionIndexPath!.row]
            let dvc = segue.destination as! InspectionFormController
            if selectedIndex == 0 {
                dvc.submit = {
                    self.submit(inspection: inspeciton, indexPath: self.selectedInspectionIndexPath!)
                }
            }
            dvc.inspection = inspeciton
        }
        
//        if segue.identifier == InspectionsController.inspectionFormControllerSegueID {
//            let inspeciton = data[selectedInspectionIndexPath!.row]
//            let dvc = segue.destination as! InspectionFormController
//            dvc.inspection = inspeciton
//        }
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
        performSegue(withIdentifier: InspectionsController.inspectionSetupControllerSegueID, sender: nil)
	}

	@IBAction func uploadTapped(_ sender: UIButton, forEvent event: UIEvent) {

		guard let indexPath = tableView.indexPath(for: event) else {
			AlertView.present(on: self, with: "Inspection was not found")
			return
		}

        let inspection = data[indexPath.row]
        indicator.alpha = 1
        indicator.startAnimating()
        navigationController?.view.isUserInteractionEnabled = false
        isBeingUploaded = true
        
        DataServices.uploadInspection(inspection: inspection) { (done) in
            self.indicator.stopAnimating()
            self.navigationController?.view.isUserInteractionEnabled = true
            self.isBeingUploaded = false
            self.indicator.alpha = 0
            self.load()
        }
	}

	@IBAction func settingsTapped(_ sender: UIBarButtonItem) {

		sender.isEnabled = false
		push(controller: SettingsController.storyboardInstance())
		sender.isEnabled = true
	}
	
	@IBAction func segmentedControlChangedValue(_ sender: UISegmentedControl) {

        updateDataForSelectedIndex();
		addNewInspectionButton.isHidden = selectedIndex == 0 ? false : true
		tableViewBottomConstraint.constant = selectedIndex == 0 ? 10 : -60
		tableView.reloadData()
	}
	
	// MARK: - Submission

	internal func submit(inspection: PFInspection, indexPath: IndexPath) {
		let alert = UIAlertController(title: "Are You Sure?", message: "You will NOT be able to edit this inspection after submission", yes: {
			self.indicator.startAnimating()
			self.navigationController?.view.isUserInteractionEnabled = false
			self.isBeingUploaded = true
			inspection.isBeingUploaded = true
			self.tableView.reloadData()
			inspection.submit(completion: { (success, error) in
				self.indicator.stopAnimating()
				inspection.isBeingUploaded = false
				self.isBeingUploaded = false
				self.navigationController?.view.isUserInteractionEnabled = true

				if let error = error {
					self.present(controller: UIAlertController(title: "Unable to Submit", message: error.message))
				}
				self.tableView.reloadData()
				guard success else{
					self.tableView.reloadData()
					return
				}
				self.showSuccessImageView()
				self.moveToSubmitted(inspection: inspection)
			}, block: { (progress) in
				inspection.progress = progress
				self.tableView.reloadRows(at: [indexPath], with: .none)
			})
		})
		present(controller: alert)
	}
	
	// MARK: -
    
	private func load() {

		indicator.startAnimating()
        
        DataServices.fetchInspections(localOnly: false, saveLocal: true) { (results: [PFInspection]) in
            print("user objs count = \(results.count)");
            
            let noObjectId = "n/a"
            results.forEach({ (item) in
                print("recieved inspection ID = \(item.id ?? noObjectId)")
            })
            
            self.inspections.draft = results.filter { $0.isSubmitted?.intValue == 0 }
            self.inspections.submitted = results.filter { $0.isSubmitted?.intValue == 1 }
            self.sort()
            self.updateDataForSelectedIndex()

            self.indicator.stopAnimating()
            self.tableView.reloadData()
        }
	}

	// Use this method to insert an inspection to the 'In Progress' tab
    @objc dynamic public func insertByDate(_ notification: Notification?) {

		if let inspection = notification?.object as? PFInspection {
            self.inspections.draft.append(inspection);
            self.inspections.draft.sort(by: { (left, right) -> Bool in
                guard let startL = left.start, let startR = right.start else{
                    return false
                }
                return startL > startR
            })

			self.tableView.reloadData()
		}
	}

    @objc dynamic private func reload() {

        load()
	}

	private func submitFromInspectionForm(_ notification: Notification?) {
		
	}
	
	// Use this method to put an inspection from 'In Progress' to 'Submitted'
	public func moveToSubmitted(inspection: PFInspection?) {

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
        case 0:
            self.data = self.inspections.draft
            print(self.data.count)
        case 1:
            self.data = self.inspections.submitted
            print(self.data.count)
        default:
            self.data = []
        }
    }

    private func configureCell(cell: InspectionCell, atIndexPath indexPath: IndexPath) {

        let inspection = data[indexPath.row]
        var date = ""

        if let start = inspection.start {
            date = start.inspectionFormat()
        }
        
        if let end = inspection.end {
            date += " - \(end.inspectionFormat())"
        }
        
        cell.setData(title: inspection.title, time: date, isLocal: inspection.isStoredLocally, progress: inspection.progress , isBeingUploaded: inspection.isBeingUploaded , isEnabled: self.isBeingUploaded, linkedProject: inspection.project)
    }
    
    // MARK: -
    
    private var selectedIndex: Int {

        return segmentedControl.selectedSegmentIndex
    }

    private func style() {

        addNewInspectionButton.layer.cornerRadius = 5
        addNewInspectionButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addNewInspectionButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        addNewInspectionButton.layer.shadowOpacity = 0.7
        addNewInspectionButton.layer.shadowRadius = 4
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

extension InspectionsController: CLLocationManagerDelegate {
    // nothing to do
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
        
        let d = data[indexPath.row]
        if selectedIndex == Sections.Submitted.rawValue && !d.isStoredLocally {
            DataServices.fetchFullInspection(inspection: d) {
                self.selectedInspectionIndexPath = indexPath
                self.performSegue(withIdentifier: InspectionsController.inspectionFormControllerSegueID, sender: nil)
            }
            
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
		let action = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            let inspection = self.data[indexPath.row]
            if let idx = self.inspections.submitted.index(of: inspection) {
                self.inspections.submitted.remove(at: idx)
                self.updateDataForSelectedIndex()
                inspection.deleteAllData()
            }

            try? inspection.unpin()
            tableView.deleteRows(at: [indexPath], with: .none)
		}

		return [action]
	}
}
