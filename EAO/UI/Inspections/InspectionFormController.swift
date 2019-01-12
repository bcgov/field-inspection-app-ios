//
//  InspectionForm.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-30.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import Parse
final class InspectionFormController: UIViewController{

    //MARK: IB Outlets
    @IBOutlet fileprivate var addButton : UIButton!
	@IBOutlet fileprivate var indicator : UIActivityIndicatorView!
	@IBOutlet fileprivate var tableView : UITableView!

    //MARK: variables
    @objc var inspection : Inspection!
    @objc var observations = [Observation]()
	
    struct Alerts{
        static let error = UIAlertController(title: "ERROR!", message: "Inspection failed to be uploaded to the server.\nPlease try again")
    }

    fileprivate var isReadOnly: Bool{
        return inspection.isSubmitted == true
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load()
    }
    
    func style() {
        addButton.layer.cornerRadius = 5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        addButton.layer.shadowOpacity = 0.7
        addButton.layer.shadowRadius = 4
    }

	@IBAction fileprivate func backTapped(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		popViewController()
	}
	
	@IBAction fileprivate func saveTapped(_ sender: UIBarButtonItem) {

        sender.isEnabled = false
        let inspectionSetupController = InspectionSetupController.storyboardInstance() as! InspectionSetupController
        inspectionSetupController.inspection = inspection
        pushViewController(controller: inspectionSetupController)
        sender.isEnabled = true
	}

	@IBAction fileprivate func addTapped(_ sender: UIButton) {

        let newObservationManager = NewObservationElementManager()
        self.present(newObservationManager.getVCFor(inspection: inspection), animated: true, completion: nil)
	}


	fileprivate func load(){
        
        if let observations = DataServices.fetchObservations(for: inspection) {
            self.observations = observations
        } else {
            AlertView.present(on: self, with: "Error occured while retrieving inspections from local storage")
        }
        self.tableView.reloadData()
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
		return observations.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(identifier: "InspectionFormCell") as! InspectionFormCell
		cell.setData(number: "\(indexPath.row+1)", title: observations[indexPath.row].title, time: observations[indexPath.row].createdAt.inspectionFormat(),isReadOnly: isReadOnly)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newObservationManager = NewObservationElementManager()
        self.present(newObservationManager.getEditVCFor(observation: observations[indexPath.row], inspection: inspection, isReadOnly: isReadOnly), animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
    
}
