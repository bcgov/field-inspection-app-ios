//
//  InspectionSetupController.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-30.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import Parse
import RealmSwift

final class InspectionSetupController: UIViewController {
    
	// MARK: - IB Outlets
	@IBOutlet fileprivate var button: UIButton!
	@IBOutlet fileprivate var indicator: UIActivityIndicatorView!
	@IBOutlet fileprivate var scrollView: UIScrollView!
	@IBOutlet fileprivate var linkProjectButton: UIButton!
	@IBOutlet fileprivate var titleTextField: UITextField!
	@IBOutlet fileprivate var subtextTextField: UITextField!
	@IBOutlet fileprivate var numberTextField: UITextField!
	@IBOutlet fileprivate var startDateButton: UIButton!
	@IBOutlet fileprivate var endDateButton: UIButton!
	
	@IBOutlet fileprivate var arrow_1: UIImageView!
	@IBOutlet fileprivate var arrow_2: UIImageView!
	@IBOutlet fileprivate var arrow_3: UIImageView!
    @IBOutlet weak var selectTeamButton: UIButton!
    @IBOutlet weak var popUpContainer: UIView!

    // MARK: variables
    struct Alerts {
        static let fields = UIAlertController(title: "Incomplete", message: "Please fill out all fields")
        static let dates = UIAlertController(title: "Dates", message: "Please make sure end date goes after start date")
        static let error = UIAlertController(title: "ERROR!", message: "Inspection failed to be saved,\nPlease try again")
    }
    
    var inspection: Inspection?
    
    private static let showInspectionFormSegueID = "showInspectionForm"
    private static let showProjectListSegueSegueID = "showProjectList"

    fileprivate var isNew = false
    fileprivate var dates = [String: Date]()
    fileprivate var startDate: Date?
    fileprivate var endDate: Date?
    fileprivate var teamID: String = ""
    
    fileprivate var isReadOnly: Bool {
        return inspection?.isSubmitted == true
    }

    // MARK: -
    override func viewDidLoad() {
        style()
        addDismissKeyboardOnTapRecognizer(on: scrollView)
        if inspection == nil {
            subtextTextField.text = PFUser.current()?.username
            isNew = true
        } else {
            button.isHidden = true
        }
        setMode()
        populate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObservers()
    }
    
    func style() {
        button.layer.cornerRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == InspectionSetupController.showProjectListSegueSegueID, let destinationVC = segue.destination as? ProjectListController {
            destinationVC.result = { (title) in
                guard let title = title else {
                    return
                }
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.linkProjectButton.setTitle(title, for: .normal)
            }
        }

        if segue.identifier == InspectionSetupController.showInspectionFormSegueID, let destinationVC = segue.destination as? InspectionFormController {
            destinationVC.inspection = inspection
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.navigationController?.viewControllers.remove(at: 1)
            }
            self.setMode()
        }
    }
    
    @IBAction func selectTeamAction(_ sender: UIButton!) {
        let team = TeamSearch()
        
        sender.isEnabled = false
        
        DataServices.getTeams { (done, teams) in
            sender.isEnabled = true

            guard let teams = teams else {
                return
            }
            
            if done {
                let _ = team.getVC(teams: teams, callBack: { (done, selected) in
                    if let selectedTeamID = selected?.objectID, done {
                        
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.teamID = selectedTeamID
                        self.selectTeamButton.setTitle(selected?.name, for: .normal)
                        
                        team.remove(from: self.popUpContainer, then: true)
                    } else {
                        team.remove(from: self.popUpContainer, then: true)
                    }
                })
                team.display(in: self.popUpContainer, on: self)
            }
        }
    }
	
	//sender: tag 10 is start date button, tag 11 is end date button
	@IBAction fileprivate func dateTapped(_ sender: UIButton) {
        
        self.navigationController?.navigationBar.isTranslucent = true
        if sender.tag == 10 {
            // start date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let initialDate = formatter.date(from: "2000/01/01 12:00")
            DatePickerController.present(on: self, minimum: initialDate, completion: { (date)
                in
                guard let date = date else { return }
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                sender.setTitle(date.datePickerFormat(), for: .normal)
                self.dates[sender.tag == 10 ? "start" : "end"] = date
                self.startDate = date

                if self.endDate != nil {
                    self.endDate = nil
                    self.endDateButton.setTitle("", for: .normal)
                    self.dates.removeValue(forKey: "end")
                }
                self.navigationController?.navigationBar.isTranslucent = false
            })
        } else {
            // end date
            if startDate == nil {
                // warn start date first
                self.showWarningAlert(message: "Start date must be selected before end date")
                self.navigationController?.navigationBar.isTranslucent = false
            } else {
                // show picker with start date as min date
                DatePickerController.present(on: self, minimum: startDate, completion: { (date) in
                    guard let date = date else { return }
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    sender.setTitle(date.datePickerFormat(), for: .normal)
                    self.dates[sender.tag == 10 ? "start" : "end"] = date
                    self.endDate = date
                    self.navigationController?.navigationBar.isTranslucent = false
                })
            }
        }
	}
	
	@IBAction fileprivate func saveTapped(_ sender: UIControl) {
        
        sender.isEnabled = false
        indicator.startAnimating()
        
        guard let inspection = validate() else {
            sender.isEnabled = true
            self.indicator.stopAnimating()
            return
        }
        
        let result = DataServices.add(inspection: inspection, isStoredLocally: true)
        self.indicator.stopAnimating()
        
        if result == true {
            
            if self.isNew {
                Notification.post(name: .insertByDate, inspection)
            } else {
                Notification.post(name: .reload)
            }
            
            if self.isNew {
                self.isNew = false
                if inspection.id.isEmpty == false {
                    self.performSegue(withIdentifier: InspectionSetupController.showInspectionFormSegueID, sender: nil)
                }
            }
        } else {
            sender.isEnabled = true
            self.presentAlert(title: "ERROR!", message: "Inspection failed to save")
        }
    }

	fileprivate func setMode() {
        
		if isReadOnly {
			linkProjectButton.isEnabled = false
			titleTextField.isEnabled    = false
			subtextTextField.isEnabled  = false
			numberTextField.isEnabled   = false
			startDateButton.isEnabled   = false
			endDateButton.isEnabled     = false
			navigationItem.rightBarButtonItem = nil
			arrow_1.isHidden = true
			arrow_2.isHidden = true
			arrow_3.isHidden = true 
		} else if isNew {
			//new
			navigationItem.rightBarButtonItem = nil
		} else {
			//modifying
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped(_:)))
			navigationItem.rightBarButtonItem?.isEnabled = false
		}
	}
	
	// MARK: -
	@objc func populate() {
        
		guard let inspection = inspection else {
            return
        }
        
		linkProjectButton.setTitle(inspection.project, for: .normal)
		startDateButton.setTitle(inspection.start?.datePickerFormat(), for: .normal)
		endDateButton.setTitle(inspection.end?.datePickerFormat() ?? "Inspection End Date", for: .normal)
		titleTextField.text = inspection.title
		subtextTextField.text = inspection.subtext
		numberTextField.text = inspection.number

        if let teamID = inspection.teamID, let team = DataServices.shared.getTeam(with: teamID) {
            self.teamID = teamID
            selectTeamButton.setTitle(team.name, for: .normal)
        }

        dates["start"] = inspection.start
        dates["end"] = inspection.end
	}
    
    @objc func validate() -> Inspection? {
        
        if linkProjectButton.title(for: .normal) == "Link Project" || titleTextField.text?.isEmpty() == true || subtextTextField.text?.isEmpty() == true || dates["start"] == nil {
            // remove ^
            presentAlert(controller: Alerts.fields)
            return nil
        }
        
        if self.teamID == "" {
            presentAlert(controller: Alerts.fields)
            return nil
        }

        if validateDates() == false {
            presentAlert(controller: Alerts.dates)
            return nil
        }
        
        if self.isNew {
            
            inspection = Inspection()
            inspection?.userId = PFUser.current()?.objectId
            inspection?.id = UUID().uuidString
            
            inspection?.project = linkProjectButton.title(for: .normal)
            inspection?.title = titleTextField.text
            inspection?.subtext = subtextTextField.text
            inspection?.number = numberTextField.text
            inspection?.start = dates["start"]
            inspection?.end = dates["end"]
            
            inspection?.isSubmitted = false
            inspection?.teamID = self.teamID
        } else {
            
            guard let realm = try? Realm() else {
                print("Unable open realm")
                return nil
            }
            
            do {
                try realm.write {
                    inspection?.project = linkProjectButton.title(for: .normal)
                    inspection?.title = titleTextField.text
                    inspection?.subtext = subtextTextField.text
                    inspection?.number = numberTextField.text
                    inspection?.start = dates["start"]
                    inspection?.end = dates["end"]
                    inspection?.isSubmitted = false
                    inspection?.teamID = self.teamID
                }
            } catch let error {
                print("Realm save exception \(error.localizedDescription)")
                return nil
            }
        }
        return inspection
    }
    
    @objc func validateDates() -> Bool {
        
        guard let startDate = dates["start"],
            let endDate = dates["end"] else {
                return dates["start"] != nil
        }
        return startDate <= endDate
    }
}

// MARK: -
extension InspectionSetupController: KeyboardDelegate {
    
	func keyboardWillShow(with height: NSNumber) {
        scrollView.contentInset.bottom = CGFloat(height.floatValue)
	}
    
	func keyboardWillHide() {
		scrollView.contentInset.bottom = 0
	}
}

// MARK: -
extension InspectionSetupController: UITextFieldDelegate {
    
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		navigationItem.rightBarButtonItem?.isEnabled = true
		var length = textField.text?.count ?? 0
		length += string.count
		length -= range.length
		return length < Constants.textFieldLenght
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
