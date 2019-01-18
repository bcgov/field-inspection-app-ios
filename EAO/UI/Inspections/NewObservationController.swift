//
//  ObservationElementController.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-30.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import Parse
import MapKit

final class NewObservationController: UIViewController {
    
    // MARK: IB Outlets
    @IBOutlet fileprivate var arrow_0: UIImageView!
    @IBOutlet fileprivate var descriptionTextView: UITextView!
    @IBOutlet fileprivate var indicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var titleTextField: UITextField!
    @IBOutlet fileprivate var requirementTextField: UITextField!
    @IBOutlet fileprivate var GPSLabel: UIButton!
    @IBOutlet fileprivate var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var descriptionButton: UIButton!

    // MARK: variables
    enum Alerts {
        static let fields = UIAlertController(title: "All Fields Required", message: "Please fill out 'Title', 'Requirement', and 'Description' fields")
    }
    enum Constants {
        static let cellWidth = (UIScreen.width-25)/CGFloat(Constants.itemsPerRow)
        static let itemsPerRow = 4
    }

    let resultCellReuseIdentifier = "ResultCell"
    let resultCellXibName = "RecultCollectionViewCell"
    let mediaCellReuseIdentifier = "MediaOptionCell"
    let mediaCellXibName = "OptionCollectionViewCell"

    private static let showDescriptionSegueID = "showDescription"
    private static let addPhotoSegueID = "addPhoto"
    private static let goToUploadPhotoSegueID = "goToUploadPhoto"
    
    @objc let maximumNumberOfPhotos = 20
    fileprivate var locationManager = CLLocationManager()
    @objc var saveAction: ((Observation)->Void)?
    @objc var inspection: Inspection!
    @objc var observation: Observation!
    @objc var photos: [Photo]?
    @objc var didMakeChange = false
    
    let galleryManager = GalleryManager()

    @objc var isReadOnly: Bool {
        return inspection.isSubmitted == true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == NewObservationController.addPhotoSegueID || identifier == NewObservationController.goToUploadPhotoSegueID {
            if photos?.count == maximumNumberOfPhotos {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.presentAlert(title: "You've reached maximum number of photos per element", message: nil)
                }
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == NewObservationController.showDescriptionSegueID, let textViewController = segue.destination as? TextViewController {
            
            if self.descriptionTextView.text != "Tap to enter description"{
                textViewController.initialText = self.descriptionTextView.text
            }
            
            textViewController.title = "Element Description"
            textViewController.result = { (text) in
                if self.descriptionTextView.text == "Tap to enter description"{
                    if let text = text, !text.isEmpty() {
                        self.descriptionTextView.text = text
                    }
                } else {
                    if let text = text,!text.isEmpty() {
                        self.descriptionTextView.text = text
                    } else {
                        
                        self.descriptionTextView.text = "Tap to enter description"
                    }
                }
            }
        }
        
        if segue.identifier == NewObservationController.addPhotoSegueID, let uploadPhotoController = segue.destination as? UploadPhotoController {
            
            uploadPhotoController.observation = observation
            uploadPhotoController.uploadPhotoAction = { (photo) in
                if let photo = photo {
                    self.didMakeChange = true
                    if self.photos == nil {
                        self.photos = []
                    }
                    self.photos?.append(photo)
                }
                self.collectionViewHeightConstraint.constant = self.getConstraintHeight()
                self.view.layoutIfNeeded()
                self.collectionView.reloadData()
            }
        }
        
        if segue.identifier == NewObservationController.goToUploadPhotoSegueID, let uploadPhotoController = segue.destination as? UploadPhotoController {
            
            if photos?.count == maximumNumberOfPhotos {
                presentAlert(title: "You've reached maximum number of photos per element", message: nil)
                return
            }
            
            uploadPhotoController.observation = observation
            uploadPhotoController.uploadPhotoAction = { (photo) in
                if let photo = photo {
                    self.didMakeChange = true
                    if self.photos == nil {
                        self.photos = []
                    }
                    self.photos?.append(photo)
                }
                self.collectionViewHeightConstraint.constant = self.getConstraintHeight()
                self.view.layoutIfNeeded()
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: -
    override func viewDidLoad() {
        setUpCollectionView()
        addDismissKeyboardOnTapRecognizer(on: scrollView)
        populate()
        if observation == nil {
            observation = Observation()
        }
        if isReadOnly {
            navigationItem.rightBarButtonItem = nil
            titleTextField.isEnabled = false
            requirementTextField.isEnabled = false
            descriptionButton.isEnabled = false
            arrow_0.isHidden = true
            view.addConstraint(NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60))
        } else {
            view.addConstraint(NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60))
        }
        view.layoutIfNeeded()
        GPSLabel.setTitle("GPS: \(observation?.coordinate?.printableString() ?? locationManager.coordinateAsString() ?? "unavailable")", for: .normal)
    }

    // MARK: -
    @IBAction func addVoiceTapped(_ sender: UIButton) {
        presentAlert(title: "This feature is coming soon", message: nil)
    }

    @IBAction func addVideoTapped(_ sender: UIButton) {
        presentAlert(title: "This feature is coming soon", message: nil)
    }

    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        
        if isReadOnly {
            popViewController()
            return
        }
        if didMakeChange {
            
            let alert = UIAlertController(title: "Would you like to save this observation element?", message: nil, yes: {
                self.saveTapped(sender)
            }, cancel: {
                self.popViewController()
            })
            presentAlert(controller: alert)
        } else {
            popViewController()
        }
    }

    @IBAction fileprivate func saveTapped(_ sender: UIBarButtonItem) {
        
        guard validate() else {
            return
        }

        indicator.startAnimating()
        saveAction?(self.observation)
        observation.title = titleTextField.text
        observation.requirement = requirementTextField.text
        observation.observationDescription = descriptionTextView.text

        if observation.inspectionId == nil {
            observation.inspectionId = inspection.id
        }
        observation.id = UUID().uuidString
        indicator.stopAnimating()
    }

    // MARK: -
    fileprivate func populate() {
        guard let observation = observation else {
            self.photos = []
            self.collectionViewHeightConstraint.constant = Constants.cellWidth
            self.view.layoutIfNeeded()
            return
        }
        indicator.startAnimating()
        titleTextField.text = observation.title
        requirementTextField.text = observation.requirement
        descriptionTextView.text = observation.observationDescription
    }

    fileprivate func getConstraintHeight()->CGFloat {
        guard let photosCount = photos?.count else { return 0 }
        if photosCount == 0 {
            return Constants.cellWidth
        }
        var numberOfRows = Double(photosCount+(isReadOnly ? 0 :1))
        numberOfRows	/= Double(Constants.itemsPerRow)
        numberOfRows	 = ceil(numberOfRows)
        var height = CGFloat(numberOfRows)
        height	  *= Constants.cellWidth
        height    += CGFloat(numberOfRows-1)*5
        return height
    }
    
    func gotToGallery() {
        // TOFIX:
        //        self.present(galleryManager.getVC(mode: GalleryMode.Image), animated: true, completion: nil)
    }
    
    func goToUploadPhoto() {
        performSegue(withIdentifier: NewObservationController.goToUploadPhotoSegueID, sender: nil)
    }
}

extension NewObservationController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func setUpCollectionView() {

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(UINib(nibName: resultCellXibName, bundle: nil), forCellWithReuseIdentifier: resultCellReuseIdentifier)
        self.collectionView.register(UINib(nibName: mediaCellXibName, bundle: nil), forCellWithReuseIdentifier: mediaCellReuseIdentifier)

        // set size of cells
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = CGSize(width: 100, height: 100)
    }

    private func photoCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(identifier: "PhotoCell", indexPath: indexPath) as! ObservationElementPhotoCell
        cell.setData(image: photos?[indexPath.row].image)
        return cell
    }

    private func addNewtPhotoCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(identifier: "AddNewPhotoCell", indexPath: indexPath) as! ObservationElementAddNewPhotoCell

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isReadOnly {
            return photos?.count ?? 0
        }

        if self.photos == nil {
            return 2
        } else {
            return photos!.count + 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isReadOnly {
            if indexPath.row > 1 {
                let cell: RecultCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: resultCellReuseIdentifier, for: indexPath) as! RecultCollectionViewCell
                cell.setImage(image: photos![indexPath.row - 2].image!)
                return cell
            } else if indexPath.row < 2 {
                let cell: OptionCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: mediaCellReuseIdentifier, for: indexPath) as! OptionCollectionViewCell
                if indexPath.row == 0 {
                    cell.imsgeView.image = #imageLiteral(resourceName: "galleryicon")
                } else {
                    cell.imsgeView.image = #imageLiteral(resourceName: "cameraicon")
                }
                return cell
            }
        }
        let cell: RecultCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: resultCellReuseIdentifier, for: indexPath) as! RecultCollectionViewCell
        cell.setImage(image: photos![indexPath.row].image!)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < 2 {
            if indexPath.row == 0 {
                // go to gallery
                gotToGallery()
            } else {
                // go to camera
                goToUploadPhoto()
            }
        } else {
            let uploadPhotoController = UploadPhotoController.storyboardInstance() as! UploadPhotoController
            uploadPhotoController.isReadOnly = inspection.isSubmitted
            uploadPhotoController.observation = observation
            uploadPhotoController.photo = photos?[indexPath.row]
            pushViewController(controller: uploadPhotoController)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.cellWidth, height: Constants.cellWidth)
    }
    
    fileprivate func validate() ->Bool {
        if titleTextField.text?.isEmpty() == true {
            presentAlert(controller: Alerts.fields)
            return false
        }
        if requirementTextField.text?.isEmpty() == true {
            presentAlert(controller: Alerts.fields)
            return false
        }
        if descriptionTextView.text == "Tap to enter description"{
            presentAlert(controller: Alerts.fields)
            return false
        }
        return true
    }
}

extension NewObservationController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        didMakeChange = true
        var length = textField.text?.count ?? 0
        length += string.count
        length -= range.length
        return length < 500
    }
}
