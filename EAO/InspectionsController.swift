//
//  EAOInspectionsController.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-30.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import MapKit
import CoreLocation
import Parse

final class InspectionsController: UIViewController, CLLocationManagerDelegate{
	//MARK: Properties
	@objc var isBeingUploaded = false
	@objc var inspections = [Int:[PFInspection]]()
	@objc var locationManager = CLLocationManager()
	//MARK: IB Outlets
	@IBOutlet var tableView: UITableView!
	@IBOutlet fileprivate var addNewInspectionButton: UIButton!
	@IBOutlet fileprivate var tableViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet fileprivate var segmentedControl: UISegmentedControl!
	@IBOutlet fileprivate var indicator: UIActivityIndicatorView!

	//MARK: IB Actions
	@IBAction func addInspectionTapped(_ sender: UIButton) {
		sender.isEnabled = false
		let inspectionSetupController = InspectionSetupController.storyboardInstance() as! InspectionSetupController
		push(controller: inspectionSetupController)
		sender.isEnabled = true
	}

	@IBAction func editTapped(_ sender: UIButton, forEvent event: UIEvent) {
		guard let indexPath = tableView.indexPath(for: event), let inspection = inspections[0]?[indexPath.row], inspection.id != nil else{
			return
		}
		let inspectionFormController = InspectionFormController.storyboardInstance() as! InspectionFormController
		inspectionFormController.inspection = inspections[selectedIndex]?[indexPath.row]
		push(controller: inspectionFormController)
	}

	@IBAction func uploadTapped(_ sender: UIButton, forEvent event: UIEvent) {
		guard let indexPath = tableView.indexPath(for: event),let inspection = inspections[0]?[indexPath.row] else{
			AlertView.present(on: self, with: "Inspection was not found")
			return
		}
//        submit(inspection: inspection, indexPath: indexPath)



        self.indicator.alpha = 1
        self.indicator.startAnimating()
        self.navigationController?.view.isUserInteractionEnabled = false
        self.isBeingUploaded = true
//        PFManager.shared.getObservationsFor(inspection: inspection) { (done, observations) in
//            if done {
//                PFManager.shared.getVideosFor(observationID: ((observations?.first)?.id!)! , completion: { (done, videos) in
//                    if done {
//                        print(videos?.first?.getURL())
//                    } else {
//
//                    }
//                })
//            } else {
//
//            }
//        }

        PFManager.shared.uploadInspection(inspection: inspection) { (done) in
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
		addNewInspectionButton.isHidden = selectedIndex == 0 ? false : true
		tableViewBottomConstraint.constant = selectedIndex == 0 ? 10 : -60
		//view.layoutIfNeeded()
		tableView.reloadData()
	}
	
	//MARK: -
	override func viewDidLoad() {
		super.viewDidLoad()
        style()
        addObserver(#selector(insertByDate(_ :)), .insertByDate)
		addObserver(#selector(reload), .reload)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		tableView.contentInset.bottom = 10
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		self.load()
	}

	//MARK: - Submission
	@objc func submit(inspection: PFInspection, indexPath: IndexPath){
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
	
	//MARK: -
	@objc func load(){
		indicator.startAnimating()
		let query = PFInspection.query()
		query?.fromLocalDatastore()
		query?.whereKey("userId", equalTo: PFUser.current()!.objectId!)
		query?.order(byDescending: "start")
		query?.findObjectsInBackground(block: { (objects, error) in
			guard let objects = objects as? [PFInspection], error == nil else{
				return
			}
			var inspections = [Int:[PFInspection]]()
			objects.forEach({ (inspection) in
				if let status = inspection.isSubmitted?.intValue{
					if inspections[status] == nil{
						inspections[status] = []
					}
					inspections[status]?.append(inspection)
				}
			})
			self.indicator.stopAnimating()
            let submitted = inspections[1]?.sorted(by: { $0.start! > $1.start! })
            let draft = inspections[0]?.sorted(by: { $0.start! > $1.start! })
			self.inspections[0] = draft
            self.inspections[1] = submitted
			self.tableView.reloadData()
		})
	}

	///Use this method to insert an inspection to the 'In Progress' tab
	@objc public func insertByDate(_ notification: Notification?){
		if let inspection = notification?.object as? PFInspection{
			if self.inspections[0] == nil{
				self.inspections[0] = []
			}
			self.inspections[0]?.append(inspection)
			self.inspections[0]?.sort(by: { (left, right) -> Bool in
				guard let startL = left.start, let startR = right.start else{
					return false
				}
				return startL > startR
			})
			self.tableView.reloadData()
		}
	}

	@objc func reload(){
        load()
//        tableView.reloadData()
	}

	@objc func submitFromInspectionForm(_ notification: Notification?){
		
	}
	
	///Use this method to put an inspection from 'In Progress' tp 'Submitted'
	@objc public func moveToSubmitted(inspection: PFInspection?){
		if let inspection = inspection{
			guard let i = inspections[0]?.index(of: inspection) else{
				return
			}
			self.inspections[0]?.remove(at: i)
			if self.inspections[1] == nil{
				self.inspections[1] = []
			}
			self.inspections[1]?.insert(inspection, at: 0)
			self.inspections[1]?.sort(by: { (left, right) -> Bool in
				guard let startL = left.start, let startR = right.start else{
					return false
				}
				return startL > startR
			})
			self.tableView.reloadData()
		}
	}
}

//MARK: -
extension InspectionsController: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return inspections[selectedIndex]?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(identifier: "InspectionCell") as! InspectionCell
		let inspection = inspections[selectedIndex]?[indexPath.row]
		var date = ""
		if let start = inspection?.start{
			date = start.inspectionFormat()
		}
		if let end = inspection?.end{
			date += " - \(end.inspectionFormat())"
		}
		cell.setData(title: inspection?.title, time: date, isReadOnly: Bool(NSNumber(integerLiteral: selectedIndex)), progress: inspection?.progress ?? 0, isBeingUploaded: inspection?.isBeingUploaded ?? false, isEnabled: self.isBeingUploaded, linkedProject: inspection?.project)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if inspections[selectedIndex]?[indexPath.row].id != nil{
			let inspectionFormController = InspectionFormController.storyboardInstance() as! InspectionFormController
			inspectionFormController.inspection = inspections[selectedIndex]?[indexPath.row]
			if selectedIndex == 0{
				inspectionFormController.submit = {
					self.submit(inspection: self.inspections[self.selectedIndex]![indexPath.row], indexPath: indexPath)
				}
			}
			push(controller: inspectionFormController)
		} else{
			AlertView.present(on: self, with: "Couldn't proceed because of internal error", delay: 4, offsetY: -50)
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if selectedIndex == 1{
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let action = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
			if let inspection = self.inspections[1]?[indexPath.row]{
				try? inspection.unpin()
				self.inspections[1]?.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .none)
				inspection.deleteAllData()
			}
		}
		return [action]
	}
}

//MARK: -
extension InspectionsController{
	fileprivate var selectedIndex: Int{
		return segmentedControl.selectedSegmentIndex
	}
}

extension InspectionsController{
	@objc static var reference: InspectionsController?{
		return (AppDelegate.root?.presentedViewController as? UINavigationController)?.viewControllers.first as? InspectionsController
	}
}

extension InspectionsController {
    func style() {
        addNewInspectionButton.layer.cornerRadius = 5
        addNewInspectionButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addNewInspectionButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        addNewInspectionButton.layer.shadowOpacity = 0.7
        addNewInspectionButton.layer.shadowRadius = 4
    }
}


