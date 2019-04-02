//
//  NewObservationElementFormViewController.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-16.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit
import Photos
import Parse
import RealmSwift

class NewObservationElementFormViewController: UIViewController {
    
    // MARK: OUTLETS
    @IBOutlet weak var closePopupButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popUpContainer: UIView!
    @IBOutlet weak var grayScreen: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var activityIndicatorContainer: UIView!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navBarHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var popUpHeight: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaHeight: NSLayoutConstraint!
    
    static let segueShowImageGallery = "showImageGallery"
    static let segueShowVideoGallery = "showVideoGallery"
    static let segueShowAudioRecorder = "showAudioRecorder"
    
    // MARK: COMPUTED VARIABLES
    var storedPhotos = [PhotoThumb]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    // new photos added from device camera
    var newPhotos = [(PhotoThumb, Photo)]()
    
    var isValid: Bool {
        if elementTitle != "" {
            return true
        } else {
            showWarningAlert(message: "Title is required")
            return false
        }
    }
    
    var enabledPopUp: Bool = false {
        didSet {
            if enabledPopUp {
                grayScreen.alpha = 1
            } else {
                grayScreen.alpha = 0
            }
        }
    }
    
    var storedAudios = [Audio]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var showingVideoPreview: Bool = false {
        didSet {
            if showingVideoPreview {
                closePopupButton.alpha = 1
            } else {
                closePopupButton.alpha = 0
            }
        }
    }
    
    var STATIC_CELLS_COUNT: Int {
        if isReadOnly {
            return 4
        } else {
            return 5
        }
    }
    
    // MARK: VARIABLES
    var playingAudio: Bool = false
    var audioPlayer: AVAudioPlayer!
    var videoPlayer: AVPlayer!
    var imagePicker: UIImagePickerController!
    var multiSelectResult = [PHAsset]()
    
    var elementTitle: String = ""
    var elementRequirement: String = ""
    var elementoldDescription: String = ""
    var elementnewDescription: String = ""
    var currentCoordinatesString: String? = nil
    
    let separator = "\n********\n"
    
    var uniqueButtonID = 0
    var isAutofilled: Bool = false
    
    var inspection: Inspection!
    var observation: Observation!
    
    var currForm: MiFormManager?
    
    var isReadOnly: Bool = false
    
    // MARK: CONSTANTS
    var galleryManager = GalleryManager()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    // MARK: View did load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        lockdown()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = true
        
        circleContainer(view: activityIndicatorContainer.layer, height: activityIndicatorContainer.frame.height)
        initCollectionView()
        setUpObservationObject()
        setupView()
        unlock()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateImageResults()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = false
    }
    
    // when device rotates, reload collection view to re set the rizes of the cells
    // then hide or show nav bar
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionView.reloadData()
            if UIDevice.current.orientation.isLandscape {
                if self.isIpad() == false {
                    self.navBarHeight.constant = 0
                    self.saveButton.isHidden = true
                    self.cancelButton.isHidden = true
                }
            } else {
                self.navBarHeight.constant = 75
                self.saveButton.isHidden = false
                self.cancelButton.isHidden = false
            }
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == NewObservationElementFormViewController.segueShowAudioRecorder, let destinationVC = segue.destination as? AudioRecorderViewController {
            
            destinationVC.inspectionID = inspection.id
            destinationVC.observationID = observation.id
            destinationVC.callBack = { (done) in
                self.load()
            }
        }
        
        if segue.identifier == NewObservationElementFormViewController.segueShowImageGallery, let destinationVC = segue.destination as? ChooseImageViewController {
            
            destinationVC.setColors(bg: Colors.White, utilBarBG: Colors.Blue, buttonText: Colors.White, loadingBG: Colors.Blue, loadingIndicator: Colors.White)
            destinationVC.mode = .Image
            destinationVC.callBack = { done in
                self.load()
            }
        }
        
        if segue.identifier == NewObservationElementFormViewController.segueShowVideoGallery, let destinationVC = segue.destination as? ChooseImageViewController {
            
            destinationVC.setColors(bg: Colors.White, utilBarBG: Colors.Blue, buttonText: Colors.White, loadingBG: Colors.Blue, loadingIndicator: Colors.White)
            destinationVC.mode = .Video
            destinationVC.callBack = { done in
                self.load()
            }
        }
    }
    
    func isIpad() -> Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return false
        case .pad:
            return true
        case .unspecified:
            return false
        case .tv:
            return false
        case .carPlay:
            return false
        }
    }
    
    func setupView() {
        roundContainer(view: mediaContainer.layer)
        styleContainer(view: mediaContainer.layer)
        if isReadOnly {
            self.mediaHeight.constant = 0
            self.mediaContainer.alpha = 0
            saveButton.isHidden = true
        }
        self.containerHeight.constant = self.view.frame.height - 40
    }
    
    // MARK: ACTIONS
    @IBAction func cancelAction(_ sender: Any) {
        if isReadOnly {
            self.close()
        } else {
            let title = "Are you sure?"
            let description = "Your new text changes and new media loaded from the gallery will not be saved"
            showWarningAlert(title: title, description: description, yesButtonTapped: {
                self.deleteNewPhotoAssets()
                self.close()
            }) {
            }
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.lockdown()
        saveObservation()
    }
    
    @IBAction func galleryAction(_ sender: Any) {
        gotToGallery()
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        goToCamera()
    }
    
    @IBAction func theodoliteAction(_ sender: Any) {
        goToThedolite()
    }
    
    @IBAction func recordAction(_ sender: Any) {
        goToRecord()
    }
    
    @IBAction func videoAction(_ sender: Any) {
        goToVideoGallery()
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        if currForm != nil {
            enabledPopUp = false
            currForm?.remove(from: popUpContainer)
        }
        closeVideoPrev()
        stopPlayback()
        popUpContainer.layer.sublayers?.removeAll()
    }
    
    @IBAction func closeVideoPopup(_ sender: Any) {
        closeVideoPrev()
        popUpContainer.layer.sublayers?.removeAll()
    }
    
    func closeVideoPrev() {
        guard showingVideoPreview else {
            return
        }
        videoPlayer.pause()
        videoPlayer = AVPlayer()
        popUpContainer.layer.sublayers?.removeAll()
        showingVideoPreview = false
        enabledPopUp = false
    }
    
    // MARK: FUNCTIONS
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveAssets(assets: [PHAsset], currIndex: Int,  lastIndex: Int, completion: @escaping () -> Void) {
        
        if currIndex > lastIndex {
            return completion()
        }
        
        var selectedAssets = assets
        guard let asset = selectedAssets.first else {
            return completion()
        }
        let observationID = self.observation.id
        
        if asset.mediaType == .video {
            // if asset is video...
            AssetManager.sharedInstance.getVideoFromAsset(phAsset: asset, completion: { (avAsset) in
                // get url of asset, needed to generate thumbnail
                asset.getURL(completionHandler: { (videoURL) in
                    guard   let videoURL = videoURL,
                            let thumbnail = AssetManager.sharedInstance.getThumbnailForVideo(url: videoURL as NSURL) else {
                        return completion()
                    }
                    
                    DataServices.saveVideo(avAsset: avAsset, thumbnail: thumbnail, index: currIndex, observationID: observationID, description: "**Video Loaded From Gallery**", completion: { (success) in
                        if success {
                            selectedAssets.removeFirst()
                            DispatchQueue.main.async {
                                self.saveAssets(assets: selectedAssets, currIndex: (currIndex + 1), lastIndex: lastIndex, completion: completion)
                            }
                        } else {
                            return completion()
                        }
                    })
                    
                })
            })
        } else {
            // if asset is image:
            AssetManager.sharedInstance.getOriginal(phAsset: asset) { (img) in
                if DataServices.savePhoto(image: img, index: currIndex, location: asset.location, observationID: observationID, description: "**PHOTO LOADED FROM GALLERY**") {
                    // successful? Remove last asset from array and call saveAssets recursively
                    selectedAssets.removeFirst()
                    DispatchQueue.main.async {
                        self.saveAssets(assets: selectedAssets, currIndex: (currIndex + 1), lastIndex: lastIndex, completion: completion)
                    }
                } else {
                    print("could not find image")
                    return completion()
                }
            }
        }
    }
    
    func saveObservation() {
        guard isValid else {
            self.unlock()
            return
        }
        
        saveObservationAssets {
            self.saveObservationDetails()
            self.saveNewPhotos()
        }
    }
    
    func saveObservationAssets(completion: @escaping () -> Void) {
        
        var startingIndex = (storedPhotos.count - 1)
        if startingIndex < 0 {startingIndex = 0}
        let lastIndex = startingIndex + (multiSelectResult.count - 1)
        print("saving bservation assets from index: \(startingIndex), to \(lastIndex)")
        saveAssets(assets: multiSelectResult, currIndex: startingIndex, lastIndex: lastIndex) {
            return completion()
        }
    }
    
    private func saveObservationDetails() {
        
        guard let realm = try? Realm() else {
            print("Unable open realm")
            return
        }
        do {
            try realm.write {
                if let location = locationManager.location, observation.coordinate == nil {
                    observation.coordinate = RealmLocation(location: location)
                }
                
                observation.title = elementTitle
                observation.requirement = elementRequirement
                if observation.observationDescription == nil {
                    observation.observationDescription = ""
                }
                
                if let observationDescription = observation.observationDescription, elementnewDescription.isEmpty == false {
                    observation.observationDescription = observationDescription + separator + elementnewDescription
                }
                
                realm.add(observation, update: true)
            }
            self.close()
        } catch let error {
            AlertView.present(on: self, with: "Error occured while saving inspection to local storage")
            print("Realm exception \(error.localizedDescription)")
        }
        self.unlock()
    }
    
    private func setUpObservationObject() {
        // if observation is not set, create it
        // otherwise autofill data
        if observation == nil {
            observation = Observation()
            if observation.inspectionId == nil {
                observation.inspectionId = inspection.id
            }
        } else {
            autofill()
        }
    }
    
    /**
     Save photos added from device camera
     */
    private func saveNewPhotos(){
        
        guard let realm = try? Realm() else {
            print("Unable open realm")
            return
        }
        do {
            try realm.write {
                for (newThumb, newPhoto) in newPhotos {
                    realm.add(newThumb, update: true)
                    realm.add(newPhoto, update: true)
                }
            }
        } catch let error {
            print("Realm exception \(error.localizedDescription)")
        }
    }

    private func deleteNewPhotoAssets(){
        
        for (thumb, photo) in newPhotos {
            let thumbPath = FileManager.workDirectory.appendingPathComponent(thumb.id, isDirectory: false)
            let photoPath = FileManager.workDirectory.appendingPathComponent(photo.id, isDirectory: false)
            do {
                try FileManager.default.removeItem(at: thumbPath)
                try FileManager.default.removeItem(at: photoPath)
            } catch {
            }
        }
    }
    
    func autofill() {
        self.elementTitle = observation.title!
        self.elementRequirement = observation.requirement!
        self.elementoldDescription = observation.observationDescription!
        self.currentCoordinatesString = observation.coordinate?.printableString()
        self.load()
        self.isAutofilled = true
    }
    
    func load() {
        DataServices.getThumbnailsFor(observationID: observation.id) { (success, photos) in
            if success {
                self.storedPhotos = photos!
            }
        }
        DataServices.getAudiosFor(observationID: self.observation.id) { (success, audios) in
            if success {
                self.storedAudios = audios!
            }
        }
    }
    
    func updateImageResults() {
        self.lockdown()
        let newResults = galleryManager.multiSelectResult
        guard newResults.count > 0 else {
            self.unlock()
            return
        }
        
        // Don't add duplicates
        for asset in newResults {
            if self.multiSelectResult.contains(asset) == false {
                self.multiSelectResult.append(asset)
            }
        }
        self.collectionView.reloadData()
        self.unlock()
    }
    
    func styleContainer(view: CALayer) {
        view.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOffset = CGSize(width: 0, height: 2)
        view.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOpacity = 1
        view.shadowRadius = 3
    }
    
    func roundContainer(view: CALayer) {
        view.cornerRadius = 8
    }
    
    func circleContainer(view: CALayer, height: CGFloat) {
        view.cornerRadius = height/2
    }
    
    func lockdown() {
        actIndicator.startAnimating()
        self.activityIndicatorContainer.alpha = 1
        self.view.isUserInteractionEnabled = false
    }
    
    func unlock() {
        actIndicator.stopAnimating()
        self.activityIndicatorContainer.alpha = 0
        self.view.isUserInteractionEnabled = true
    }
    
    // MARK: add new elements actions
    func goToCamera() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func gotToGallery() {
        performSegue(withIdentifier: NewObservationElementFormViewController.segueShowImageGallery, sender: nil)
    }
    
    func goToVideoGallery() {
        performSegue(withIdentifier: NewObservationElementFormViewController.segueShowVideoGallery, sender: nil)
    }
    
    func goToThedolite() {
        let appHookUrl = URL(string: "theodolite://")
        
        if UIApplication.shared.canOpenURL(appHookUrl!) {
            UIApplication.shared.open(appHookUrl!, options: [:]) { (success) in
                if !success {
                }
            }
        } else {
            showWarningAlert(message: "Theodolite app is not installed")
        }
    }
    
    func goToRecord() {
        performSegue(withIdentifier: NewObservationElementFormViewController.segueShowAudioRecorder, sender: nil)
    }
}

// MARK: Collection view
extension NewObservationElementFormViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        var names = [String]()
        names.append("TitleNewObservationCollectionViewCell")
        names.append("RequirementNewObservationCollectionViewCell")
        names.append("DescriptionNewObservationCollectionViewCell")
        names.append("LabelCollectionViewCell")
        names.append("ImageCollectionViewCell")
        names.append("NewDescriptionNewObservationCollectionViewCell")
        
        for name in names {
            registerCell(name: name)
        }
    }
    
    func registerCell(name: String) {
        collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func getLabelCell(indexPath: IndexPath) -> LabelCollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getTitleCell(indexPath: IndexPath) -> TitleNewObservationCollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getRequirementCell(indexPath: IndexPath) -> RequirementNewObservationCollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getDescriptionCell(indexPath: IndexPath) -> DescriptionNewObservationCollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getNewDescriptionCell(indexPath: IndexPath) -> NewDescriptionNewObservationCollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func getImageCell(indexPath: IndexPath) -> ImageCollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storedAudios.count + storedPhotos.count + multiSelectResult.count + STATIC_CELLS_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isReadOnly {
            return getCellsForViewing(indexPath: indexPath)
        } else {
            return getCellsForEditing(indexPath: indexPath)
        }
    }
    
    func getCellsForEditing(indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = getLabelCell(indexPath: indexPath)
            cell.setup(location: currentCoordinatesString)
            return cell
        case 1:
            let cell = getTitleCell(indexPath: indexPath)
            cell.setup(text: elementTitle, enableEditing: !isReadOnly)
            return cell
        case 2:
            let cell = getRequirementCell(indexPath: indexPath)
            cell.setup(text: elementRequirement, enableEditing: !isReadOnly)
            return cell
        case 3:
            let cell = getDescriptionCell(indexPath: indexPath)
            cell.setup(text: elementoldDescription)
            return cell
        case 4:
            let cell = getNewDescriptionCell(indexPath: indexPath)
            return cell
        default:
            let index = indexPath.row - STATIC_CELLS_COUNT
            let cell = getImageCell(indexPath: indexPath)
            if index < storedPhotos.count {
                // stored photo
                cell.setWithPFThumb(photo: storedPhotos[index], type: .Thumbnail)
            } else if (index - storedPhotos.count) < multiSelectResult.count {
                // multiselect result
                cell.setWithAsset(asset: multiSelectResult[index - storedPhotos.count], type: .PHAsset)
            } else if ((index - storedPhotos.count) - multiSelectResult.count < storedAudios.count) {
                cell.setAudio(audio: storedAudios[index - storedPhotos.count - multiSelectResult.count], type: .Audio)
            } else {
                print("still gets here")
            }
            return cell
        }
    }
    
    func getCellsForViewing(indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = getLabelCell(indexPath: indexPath)
            cell.setup(location: currentCoordinatesString)
            return cell
        case 1:
            let cell = getTitleCell(indexPath: indexPath)
            cell.setup(text: elementTitle, enableEditing: !isReadOnly)
            return cell
        case 2:
            let cell = getRequirementCell(indexPath: indexPath)
            cell.setup(text: elementRequirement, enableEditing: !isReadOnly)
            return cell
        case 3:
            let cell = getDescriptionCell(indexPath: indexPath)
            cell.setup(text: elementoldDescription)
            return cell
        default:
            let index = indexPath.row - STATIC_CELLS_COUNT
            let cell = getImageCell(indexPath: indexPath)
            if index < storedPhotos.count {
                // stored photo
                cell.setWithPFThumb(photo: storedPhotos[index], type: .Thumbnail)
            } else if (index - storedPhotos.count) < multiSelectResult.count {
                // multiselect result
                cell.setWithAsset(asset: multiSelectResult[index - storedPhotos.count], type: .PHAsset)
            } else if ((index - storedPhotos.count) - multiSelectResult.count < storedAudios.count) {
                cell.setAudio(audio: storedAudios[index - storedPhotos.count - multiSelectResult.count], type: .Audio)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if !isReadOnly {
            switch indexPath.row {
            case 0...2:
                return CGSize(width: width, height: 50)
            case 3:
                if self.elementoldDescription == "" {
                    return CGSize(width: width, height: 0)
                } else {
                    return CGSize(width: width, height: 300)
                }
            case 4:
                return CGSize(width: width, height: 300)
            default:
                return CGSize(width: width/3.2, height: width/3.2)
            }
        } else {
            switch indexPath.row {
            case 0...2:
                return CGSize(width: width, height: 50)
            case 3:
                return CGSize(width: width, height: 300)
            default:
                return CGSize(width: width/3.2, height: width/3.2)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let indexRow = indexPath.row
        let statics = STATIC_CELLS_COUNT - 1
        let i = indexRow - STATIC_CELLS_COUNT
        guard indexRow >= statics else {
            return
        }
        guard i >= 0 else {
            return
        }
        if i < storedPhotos.count {
            
            let current = storedPhotos[i]
            if current.originalType == nil {
                return
            }
            
            if current.originalType == "video" {
                showPreviewOfVideo(index: storedPhotos[i].index)
            }
            
            if current.originalType == "photo" {
                showPhotoPreview(for: storedPhotos[i].index)
            }
        } else if i - storedPhotos.count < multiSelectResult.count {
            print("\(#function) multiselect")
        } else if i - storedPhotos.count - multiSelectResult.count < storedAudios.count {
            print("\(#function) audio")
            playAudioAt(index: i - storedPhotos.count - multiSelectResult.count)
        }
    }
    
    func playAudioAt(index: Int) {
        
        let audio = storedAudios[index]
        let form = MiFormManager()
        let buttonStyleBlue = MiButtonStyle(textColor: .white, bgColor: Colors.Blue, height: 50, roundCorners: true)
        let buttonStyleRed = MiButtonStyle(textColor: .white, bgColor: Colors.Red, height: 50, roundCorners: true)
        let textStyleL = LabelStyle(height: 100, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        let textStyleS = LabelStyle(height: 50, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        
        if audio.title != nil {
            form.addLabel(name: "sounddesc", text: audio.title! , style: textStyleS)
        }
        if audio.notes != nil {
            form.addLabel(name: "sounddesc", text: audio.notes! , style: textStyleL)
        }
        form.addButton(name: "playAudio\(index)", title: "Play",style: buttonStyleBlue) {
            if !self.playingAudio, let data = audio.get() {
                self.playAudio(data: data)
            }
        }
        
        form.addButton(name: "stop\(index)", title: "Stop", style: buttonStyleBlue) {
            self.stopPlayback()
        }
        
        form.addButton(name: "closesoundplayback\(index)", title: "Close", style: buttonStyleRed) {
            self.enabledPopUp = false
            self.stopPlayback()
            form.remove(from: self.popUpContainer)
        }
        
        self.enabledPopUp = true
        self.containerHeight.constant = 380
        self.currForm = form
        form.display(in: self.popUpContainer, on: self)
    }
    
    func showPreviewOfVideo(index: Int) {
        
        self.containerHeight.constant = self.view.frame.height - 200
        
        if let video = DataServices.getVideo(for: observation.id, at: index) {
            guard let assetURL = video.getURL() else {
                return
            }
            let avasset = AVAsset(url: assetURL)
            let x = AVPlayerItem(asset: avasset)
            self.videoPlayer = AVPlayer(playerItem: x)
            let playerLayer = AVPlayerLayer(player: self.videoPlayer)
            self.grayScreen.alpha = 1
            self.popUpContainer.alpha = 1
            self.containerHeight.constant = self.view.frame.height - 200
            playerLayer.frame = self.popUpContainer.bounds
            playerLayer.backgroundColor = UIColor.white.cgColor
            self.showingVideoPreview = true
            self.popUpContainer.layer.addSublayer(playerLayer)
            
            self.videoPlayer.play()
        }
    }
    
    func showPhotoPreview(for index: Int) {
        
        let form = MiFormManager()
        let style = MiButtonStyle(textColor: .white, bgColor: Colors.Blue, height: 50, roundCorners: true)
        let textStyleL = LabelStyle(height: 100, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        let textStyleS = LabelStyle(height: 50, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        let textStyleM = LabelStyle(height: 80, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        
        if let photo = DataServices.getPhoto(for: observation.id, at: index) {
            let locationString = photo.coordinate?.printableString() ?? ""
            
            if let image = photo.image {
                form.addImage(image: image)
            }
            if let caption = photo.caption, caption.count > 0 {
                form.addLabel(name: "caption", text: caption, style: textStyleL)
            }
            form.addLabel(name: "piclocation", text: locationString, style: textStyleM)
            if let timestamp = photo.timestamp {
                form.addLabel(name: "date:", text: Settings.formatter.string(from: timestamp), style: textStyleS)
            }
            form.addButton(name: "closeprev\(index)", title: "close", style: style, completion: {
                self.enabledPopUp = false
                form.remove(from: self.popUpContainer)
            })
            self.enabledPopUp = true
            self.containerHeight.constant = self.view.frame.height - 40
            self.currForm = form
            form.display(in: self.popUpContainer, on: self)
        }
    }
}

// MARK: Collection view
extension  NewObservationElementFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        promptImageDetails(image: image!)
    }
    
    func promptImageDetails(image: UIImage) {
        print(image)
        let form = MiFormManager()
        
        let commonFieldStyle = MiTextFieldStyle(titleColor: Colors.Blue, inputColor: Colors.Blue, fieldBG: .white, bgColor: .white, height: 150, roundCorners: true)
        
        let commonButtonStyle = MiButtonStyle(textColor: .white, bgColor: Colors.Blue, height: 50, roundCorners: true)
        
        let textStyleS = LabelStyle(height: 50, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        let textStyleM = LabelStyle(height: 80, roundCorners: true, bgColor: UIColor.white, labelTextColor: Colors.Blue)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowDate = Date()
        let nowDateString = formatter.string(from: nowDate)
        
        let location = self.locationManager.location!
        let lat = round(num: location.coordinate.latitude, toPlaces: 5)
        let long = round(num: location.coordinate.longitude, toPlaces: 5)
        let locationString = "lat: \(String(lat))\nLon: \(String(long))"
        
        // Add cancel button.
        form.addButton(name: "Cancel", title: "Cancel", style: commonButtonStyle, completion: {
            self.enabledPopUp = false
            form.remove(from: self.popUpContainer)
        })

        form.addImage(image: image)
        form.addField(name: "details", title: "Caption", placeholder: "", type: .TextViewInput, inputType: .Text, style: commonFieldStyle)
        form.addLabel(name: "gpsstamp", text: locationString, style: textStyleM)
        form.addLabel(name: "datestamp", text: nowDateString, style: textStyleS)
        
        form.addButton(name: "submit\(uniqueButtonID)", title: "Add", style: commonButtonStyle) {

            let results = form.getFormResults()
            var comments = ""
            if results.isEmpty == false {
                if let details = results["details"] {
                    comments = details
                }
            }
            
            // TODO:: Store nowDate
            if let (thumbnail, photo) = DataServices.preparePhoto(image: image, index: self.storedPhotos.count, location: location, observationID: self.observation.id, description: comments) {
                self.load()
                self.enabledPopUp = false
                form.remove(from: self.popUpContainer)
                self.storedPhotos.append(thumbnail)
                self.newPhotos.append(((thumbnail, photo)))
            }
        }
        
        uniqueButtonID += 1
        enabledPopUp = true
        self.containerHeight.constant = self.view.frame.height - 40
        self.currForm = form
        form.display(in: popUpContainer, on: self)
    }
}

extension NewObservationElementFormViewController: AVAudioPlayerDelegate {
    // Playback
    
    func playback(url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            if initPlay(url: url) {
                audioPlayer.play()
            }
        } else {
            // error: could not find audio file
        }
    }
    
    func stopPlayback() {
        if self.playingAudio {
            audioPlayer.stop()
            self.playingAudio = false
        }
    }
    
    func initPlay(url: URL) -> Bool {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            return true
        } catch {
            print("Error")
            return false
        }
    }
    
    func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            self.playingAudio = true
        } catch {
            print("Error")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
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

