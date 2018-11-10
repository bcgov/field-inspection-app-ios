//
//  InspectionForm.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-30.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import Parse
final class InspectionFormController: UIViewController{

    @IBOutlet fileprivate var addButton : UIButton!
	@IBOutlet fileprivate var indicator : UIActivityIndicatorView!
	@IBOutlet fileprivate var tableView : UITableView!

    @objc var inspection : PFInspection!
    @objc var observations = [PFObservation]()
	
	@IBAction fileprivate func backTapped(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		pop()
	}
	
	@IBAction fileprivate func saveTapped(_ sender: UIBarButtonItem) {

        sender.isEnabled = false
        let inspectionSetupController = InspectionSetupController.storyboardInstance() as! InspectionSetupController
        inspectionSetupController.inspection = inspection
        push(controller: inspectionSetupController)
        sender.isEnabled = true
	}

	@IBAction fileprivate func addTapped(_ sender: UIButton) {

        let newObservationManager = NewObservationElementManager()
        self.present(newObservationManager.getVCFor(inspection: inspection), animated: true, completion: nil)
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load()
    }
	
	//MARK: -
	override func viewDidLoad() {
		tableView.contentInset.bottom = 120
		if isReadOnly{
			addButton.isHidden = true 
			navigationItem.rightBarButtonItem = nil
		}
        style()
		load()
	}
 
	fileprivate func load(){
		let query = PFObservation.query()
		query?.fromLocalDatastore()
		query?.whereKey("inspectionId", equalTo: inspection.id!)
		query?.order(byDescending: "pinnedAt")
		query?.findObjectsInBackground(block: { (objects, error) in
			guard let objects = objects as? [PFObservation], error == nil else{
				AlertView.present(on: self, with: "Error occured while retrieving inspections from local storage")
				return
			}
			self.observations = objects
			self.tableView.reloadData()
		})
	}
	
	fileprivate func setElements(enabled: Bool){
		view.isUserInteractionEnabled = enabled
		enabled ? indicator.stopAnimating() : indicator.startAnimating()
		navigationItem.leftBarButtonItem?.isEnabled = enabled
	}
}

//MARK: -
extension InspectionFormController: UITableViewDataSource, UITableViewDelegate{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0{
//            return 1
//        }
		return observations.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeue(identifier: "InspectionFormHeaderCell")!
//            if isReadOnly{
//                (cell.contentView.subviews.first as? UIButton)?.setTitle("View Inspection Set Up", for: .normal)
//            } else{
//                (cell.contentView.subviews.first as? UIButton)?.setTitle("Edit Inspection Set Up", for: .normal)
//            }
//            return cell
//        }
		let cell = tableView.dequeue(identifier: "InspectionFormCell") as! InspectionFormCell
		cell.setData(number: "\(indexPath.row+1)", title: observations[indexPath.row].title, time: observations[indexPath.row].createdAt?.inspectionFormat(),isReadOnly: isReadOnly)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0{
//            return
//        }
		if observations[indexPath.row].id == nil{
			return
		}
        
//        let observationElementController = NewObservationController.storyboardInstance() as! NewObservationController
//        observationElementController.inspection = inspection
//        observationElementController.observation = observations[indexPath.row]
//        observationElementController.saveAction = { (_) in
//            self.tableView.reloadData()
//        }
//        push(controller: observationElementController)
        let newObservationManager = NewObservationElementManager()
        self.present(newObservationManager.getEditVCFor(observation: observations[indexPath.row], inspection: inspection, isReadOnly: isReadOnly), animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0{
//            return 70
//        }
		return 80
	}
}

//MARK: -
extension InspectionFormController{
	fileprivate var isReadOnly: Bool{
		return inspection.isSubmitted?.boolValue == true
	}
}

//MARK: -
extension InspectionFormController{
	struct Alerts{
		static let error = UIAlertController(title: "ERROR!", message: "Inspection failed to be uploaded to the server.\nPlease try again")
	}
}

extension InspectionFormController {
    func style() {
        addButton.layer.cornerRadius = 5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        addButton.layer.shadowOpacity = 0.7
        addButton.layer.shadowRadius = 4
    }
}



