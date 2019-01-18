//
//  NewObservationElementViewController.swift
//  AllMyPics
//
//  Created by Amir Shayegh on 2017-12-21.
//  Copyright © 2017 Amir Shayegh. All rights reserved.
//

import UIKit
import Photos
import Parse
import RealmSwift

class NewObservationElementViewController: UIViewController {
    
    // MARK: IB Outlets
    @IBOutlet fileprivate var mediaOptionsCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var grayScreen: UIView!
    @IBOutlet weak var popUpContainer: UIView!
    @IBOutlet weak var popUpContainerContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: variables
    var uniqueButtonID = 0
    var imagePicker: UIImagePickerController!
    var inspection: Inspection!
    var observation: Observation!
    var photos: [PFPhoto]?
    var storedPhotos = [PFPhoto]() {
        didSet {
            self.mediaOptionsCollection.reloadData()
        }
    }
    
    var multiSelectResult = [PHAsset]()
    
    var currentLocation: CLLocation?
    var currentCoordinatesString = ""
    
    let resultCellReuseIdentifier = "ResultCell"
    let resultCellXibName = "RecultCollectionViewCell"
    let mediaCellReuseIdentifier = "MediaOptionCell"
    let mediaCellXibName = "OptionCollectionViewCell"
    let ImageCollectionXibName = "ImageCollectionTableViewCell"
    let ImageCollectionReuseIdentified = "ImageCollectionTableViewCell"
    
    let separator = "\n********\n"
    
    let OPTIONS_COUNT = 3
    
    var isAutofilled: Bool = false
    
    let galleryManager = GalleryManager()
    let locationManager = CLLocationManager()
    
    var elementTitle: String = "" {
        didSet {
            print(elementTitle)
        }
    }
    var elementRequirement: String = "" {
        didSet {
            print(elementRequirement)
        }
    }
    var elementoldDescription: String = "" {
        didSet {
            print(elementoldDescription)
        }
    }
    var elementnewDescription: String = "" {
        didSet {
            print(elementnewDescription)
        }
    }
    
    var isValid: Bool {
        if elementTitle != "" {
            return true
        } else {
            self.warn(message: "Title is required")
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        lock()
        setUpObservationObject()
        setUpCollectionView()
        setUpTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateImageResults()
        unlock()
    }
    
    func setUpObservationObject() {
        if observation == nil {
            observation = Observation()
            if observation.inspectionId == nil {
                observation.inspectionId = inspection.id
            }
        } else {
            autofill()
        }
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        close()
    }
    
    func style() {
        // set gallery view's color theme
        galleryManager.setColors(bg_hex: "ffffff", utilBarBG_hex: "4667a2", buttonText_hex: "ffffff", loadingBG_hex: "4667a2", loadingIndicator_hex: "ffffff")
        activityIndicatorContainer.layer.cornerRadius = self.activityIndicatorContainer.frame.height/2
        activityIndicatorContainer.backgroundColor = UIColor(hex: "083760")
        activityIndicator.color = UIColor(hex: "ffffff")
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        guard isValid else {
            return
        }
        self.lock()
        
        guard let realm = try? Realm() else {
            print("Unable open realm")
            self.unlock()
            return
        }
        
        do {
            try realm.write {
                if observation.coordinate == nil {
                    observation.coordinate = RealmLocation(location: locationManager.location)
                }
                observation.title = elementTitle
                observation.requirement = elementRequirement
                if observation.observationDescription == nil {
                    observation.observationDescription = ""
                }
                if elementnewDescription != "" {
                    observation.observationDescription = observation.observationDescription! + separator + elementnewDescription
                }
                realm.add(observation, update: true)
            }
        } catch let error {
            print("Realm save exception \(error.localizedDescription)")
        }
        
        self.unlock()
    }
    
    func autofill() {
        self.elementTitle = observation.title!
        self.elementRequirement = observation.requirement!
        self.elementoldDescription = observation.observationDescription!
        self.currentCoordinatesString = observation.coordinate?.printableString() ?? ""
        self.loadPhotos()
        self.isAutofilled = true
    }
    
    fileprivate func loadPhotos() {
        //TOFIX
        //        guard let query = PFPhoto.query() else {
        //            self.unlock()
        //            return
        //        }
        //
        //        query.fromLocalDatastore()
        //        query.whereKey("observationId", equalTo: observation.id!)
        //        query.findObjectsInBackground(block: { (photos, error) in
        //            guard let storedPhotos = photos as? [PFPhoto], error == nil else {
        //                self.lock()
        //                AlertView.present(on: self, with: "Couldn't retrieve observation photos")
        //                return
        //            }
        //
        //            for photo in storedPhotos {
        //                if let id = photo.id {
        //                    print("iiiiii = \(id)")
        //                    let url = URL(fileURLWithPath: FileManager.directory.absoluteString).appendingPathComponent(id, isDirectory: true)
        //                    photo.image = UIImage(contentsOfFile: url.path)
        //                    self.storedPhotos.append(photo)
        //                }
        //            }
        //            self.mediaOptionsCollection.reloadData()
        //            self.unlock()
        //        })
    }
    
    func updateImageResults() {
        self.lock()
        let newResults = galleryManager.multiSelectResult
        if newResults.count == 0 {self.unlock();return}
        // Don't add duplicates
        for asset in newResults {
            if !self.multiSelectResult.contains(asset) {
                self.multiSelectResult.append(asset)
            }
        }
        self.saveSelectedPhotos()
        self.mediaOptionsCollection.reloadData()
    }
    
    func lock() {
        activityIndicator.isHidden = false
        activityIndicatorContainer.isHidden = false
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func unlock() {
        activityIndicator.isHidden = true
        activityIndicatorContainer.isHidden = true
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    func saveSelectedPhotos() {
        //TOFIX
        //        if multiSelectResult.isEmpty{
        //            mediaOptionsCollection.reloadData()
        //            return
        //        }
        //        self.lock()
        //        let asset = multiSelectResult.last
        //        let photo = PFPhoto()
        //        photo.observationId = observation.id
        //        photo.id = UUID().uuidString
        //        photo.timestamp = asset?.creationDate
        //        photo.coordinate = PFGeoPoint(location: asset?.location)
        //        AssetManager.sharedInstance.getOriginal(phAsset: asset!, completion: { (image) in
        //            photo.image = image
        //            let data = image.toData(quality: .medium)
        //            do {
        //                try data.write(to: FileManager.directory.appendingPathComponent(photo.id!, isDirectory: true))
        //                photo.pinInBackground { (success, error) in
        //                    if success && error == nil {
        //                        self.multiSelectResult.removeLast()
        //                        if self.multiSelectResult.isEmpty {
        //                            self.storedPhotos.removeAll()
        //                            self.loadPhotos()
        //                        } else {
        //                            self.saveSelectedPhotos()
        //                        }
        //                    } else {
        //                        AlertView.present(on: self, with: "Error occured while saving image to local storage")
        //                        self.unlock()
        //                    }
        //                }
        //            } catch {
        //                AlertView.present(on: self, with: "Error occured while saving image to local storage")
        //                self.unlock()
        //            }
        //        })
    }
    
    func storePhotoTaken(image: UIImage, description: String, location: CLLocation) {
        //TOFIX
        //        self.lock()
        //        let photo = PFPhoto()
        //        photo.observationId = observation.id
        //        photo.id = UUID().uuidString
        //        photo.timestamp = Date()
        //        photo.coordinate = PFGeoPoint(location: location)
        //        let data = image.toData(quality: .medium)
        //
        //        do {
        //            try data.write(to: FileManager.directory.appendingPathComponent(photo.id!, isDirectory: true))
        //            photo.pinInBackground { (success, error) in
        //                if success && error == nil {
        //                    self.loadPhotos()
        //                    self.unlock()
        //                } else {
        //                    AlertView.present(on: self, with: "Error occured while saving image to local storage")
        //                    self.unlock()
        //                }
        //            }
        //        } catch {
        //            AlertView.present(on: self, with: "Error occured while saving image to local storage")
        //            self.unlock()
        //        }
    }
}

// Media Collection view
extension NewObservationElementViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func setUpCollectionView() {
        self.mediaOptionsCollection.delegate = self
        self.mediaOptionsCollection.dataSource = self
        
        self.mediaOptionsCollection.register(UINib(nibName: resultCellXibName, bundle: nil), forCellWithReuseIdentifier: resultCellReuseIdentifier)
        self.mediaOptionsCollection.register(UINib(nibName: mediaCellXibName, bundle: nil), forCellWithReuseIdentifier: mediaCellReuseIdentifier)
        self.mediaOptionsCollection.register(UINib(nibName: ImageCollectionXibName, bundle: nil), forCellWithReuseIdentifier: ImageCollectionReuseIdentified)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OPTIONS_COUNT + storedPhotos.count
    }
    
    func getGalleryResultCell(indexPath: IndexPath, index: Int) -> UICollectionViewCell {
        print("\(multiSelectResult.count) \(index)")
        let cell: RecultCollectionViewCell = mediaOptionsCollection.dequeueReusableCell(withReuseIdentifier: resultCellReuseIdentifier, for: indexPath) as! RecultCollectionViewCell
        cell.setUp(phAsset: multiSelectResult[index])
        return cell
    }
    
    func getSavedImageCell(indexPath: IndexPath, index: Int) -> UICollectionViewCell {
        print("\(storedPhotos.count) \(index)")
        let cell: OptionCollectionViewCell = mediaOptionsCollection.dequeueReusableCell(withReuseIdentifier: mediaCellReuseIdentifier, for: indexPath) as! OptionCollectionViewCell
        cell.imsgeView.image = storedPhotos[index].image
        return cell
    }
    
    func getGalleryOptionCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OptionCollectionViewCell = mediaOptionsCollection.dequeueReusableCell(withReuseIdentifier: mediaCellReuseIdentifier, for: indexPath) as! OptionCollectionViewCell
        cell.imsgeView.image = #imageLiteral(resourceName: "galleryicon")
        return cell
    }
    
    func getThedoliteOptionCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OptionCollectionViewCell = mediaOptionsCollection.dequeueReusableCell(withReuseIdentifier: mediaCellReuseIdentifier, for: indexPath) as! OptionCollectionViewCell
        cell.imsgeView.image = #imageLiteral(resourceName: "cameraicon")
        return cell
    }
    
    func getCameraOptionCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OptionCollectionViewCell = mediaOptionsCollection.dequeueReusableCell(withReuseIdentifier: mediaCellReuseIdentifier, for: indexPath) as! OptionCollectionViewCell
        cell.imsgeView.image = #imageLiteral(resourceName: "cameraicon")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        if index == 0 {
            return getGalleryOptionCell(indexPath: indexPath)
        } else if index == 1 {
            return getThedoliteOptionCell(indexPath: indexPath)
        } else if index == 2 {
            return getCameraOptionCell(indexPath: indexPath)
        } else {
            if !storedPhotos.isEmpty {
                if index >= OPTIONS_COUNT && index <= (storedPhotos.count + (OPTIONS_COUNT - 1)) {
                    return getSavedImageCell(indexPath: indexPath, index: index - OPTIONS_COUNT)
                } else {
                    return getGalleryResultCell(indexPath: indexPath, index: index - OPTIONS_COUNT - storedPhotos.count)
                }
            } else {
                return getGalleryResultCell(indexPath: indexPath, index: index - OPTIONS_COUNT - storedPhotos.count)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < OPTIONS_COUNT {
            switch indexPath.row {
            case 0:
                // go to gallery
                gotToGallery()
            case 1:
                // go to camera
                goToThedolite()
            default:
                goToCamera()
            }
        }
    }
    
    func goToCamera() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func gotToGallery() {
        //        self.present(galleryManager.getVC(mode: GalleryMode.Image), animated: true, completion: nil)
    }
    
    func goToThedolite() {
        let appHookUrl = URL(string: "theodolite://")
        
        if UIApplication.shared.canOpenURL(appHookUrl!) {
            UIApplication.shared.open(appHookUrl!, options: [:]) { (success) in
                if !success {
                }
            }
        } else {
            warn(message: "Theodolite app is not installed")
        }
    }
}

// Tableview
extension NewObservationElementViewController: UITableViewDelegate, UITableViewDataSource {
    
    func getTitleCell(indexPath: IndexPath) -> FormTitleTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getRequirementCell(indexPath: IndexPath) -> FormReqirementTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getOldDescriptionCell(indexPath: IndexPath) -> OldDescriptionFieldTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getNewDescriptionCell(indexPath: IndexPath) -> NewDescriptionTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getGPSLabelCell(indexPath: IndexPath) -> GPSLabelTableViewCell {
        return tableView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib1 = UINib(nibName: FormTitleTableViewCell.nibName, bundle: nil)
        let nib2 = UINib(nibName: FormReqirementTableViewCell.nibName, bundle: nil)
        let nib3 = UINib(nibName: OldDescriptionFieldTableViewCell.nibName, bundle: nil)
        let nib4 = UINib(nibName: NewDescriptionTableViewCell.nibName, bundle: nil)
        let nib5 = UINib(nibName: GPSLabelTableViewCell.nibName, bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: GPSLabelTableViewCell.reuseIdentifier)
        tableView.register(nib1, forCellReuseIdentifier: FormTitleTableViewCell.reuseIdentifier)
        tableView.register(nib2, forCellReuseIdentifier: FormReqirementTableViewCell.reuseIdentifier)
        tableView.register(nib3, forCellReuseIdentifier: OldDescriptionFieldTableViewCell.reuseIdentifier)
        tableView.register(nib4, forCellReuseIdentifier: NewDescriptionTableViewCell.reuseIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        switch index {
        case 0:
            let cell = getGPSLabelCell(indexPath: indexPath)
            if isAutofilled {
                cell.setUpForViewing(location: currentCoordinatesString)
            } else {
                cell.setUpForEditing()
            }
            return cell
            
        case 1:
            let cell = getTitleCell(indexPath: indexPath)
            cell.textField.placeholder = "Title"
            cell.setUp(text: elementTitle)
            return cell
            
        case 2:
            let cell = getRequirementCell(indexPath: indexPath)
            cell.textField.placeholder = "Requirement"
            cell.setUp(text: elementRequirement)
            return cell
            
        case 3:
            let cell = getOldDescriptionCell(indexPath: indexPath)
            if elementoldDescription == "" {
                cell.hide()
            } else {
                cell.setUp(text: elementoldDescription)
            }
            return cell
            
        case 4:
            let cell = getNewDescriptionCell(indexPath: indexPath)
            return cell
            
        default:
            let cell = getTitleCell(indexPath: indexPath)
            return cell
        }
    }
}

extension NewObservationElementViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        //        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        promptImageDetails(image: image!)
    }
    
    func promptImageDetails(image: UIImage) {
        let form = MiFormManager()
        let blue = Colors.Blue
        
        let commonFieldStyle = MiTextFieldStyle(titleColor: blue, inputColor: blue, fieldBG: .white, bgColor: .white, height: 150, roundCorners: true)
        
        commonFieldStyle.borderStyle = UITextField.BorderStyle.none
        
        let commonButtonStyle = MiButtonStyle(textColor: .white, bgColor: blue, height: 50, roundCorners: true)
        
        form.addImage(image: image)
        form.addField(name: "details", title: "Caption", placeholder: "", type: .TextViewInput, inputType: .Text, style: commonFieldStyle)
        //        form.addField(name: "details", title: "Details", placeholder: "", keyboardType: .alphabet, type: .TextViewInput, style: commonFieldStyle)
        form.addButton(name: "submit\(uniqueButtonID)", title: "Add", style: commonButtonStyle) {
            let results = form.getFormResults()
            var comments = ""
            
            if results.isEmpty == false {
                if let details = results["details"] {
                    comments = details
                }
            }
            
            self.storePhotoTaken(image: image, description: comments, location: self.locationManager.location!)
            
            self.grayScreen.alpha = 0
            form.remove(from: self.popUpContainer)
        }
        
        uniqueButtonID += 1
        
        popUpContainerContainer.layer.cornerRadius = 8
        grayScreen.alpha = 1
        form.display(in: popUpContainer, on: self)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

