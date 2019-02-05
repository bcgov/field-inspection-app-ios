//
//  UploadPhotoController.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-15.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import MapKit
import Parse
import Photos

class UploadPhotoController: UIViewController, KeyboardDelegate {
    
    struct Alerts {
        static let error = UIAlertController(title: "Picture Required", message: "Please provide a picture to save")
    }

    // MARK: -
    @IBOutlet fileprivate var indicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var timestampLabel: UILabel!
    @IBOutlet fileprivate var gpsLabel: UILabel!
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var uploadButton: UIButton!
    @IBOutlet fileprivate var uploadLabel: UILabel!
    @IBOutlet fileprivate var captionTextView: UITextView!

	fileprivate var didMakeChange = false
	@objc var isReadOnly = false
	@objc var photo: Photo!
	@objc var observation: Observation!
	@objc var uploadPhotoAction: ((_ photo: Photo?)-> Void)?
    
    fileprivate var locationManager = CLLocationManager()
	fileprivate var date: Date? {
		didSet {
			timestampLabel.text = date?.timeStampFormat()
		}
	}
    
	fileprivate var location: CLLocation? {
		didSet {
			gpsLabel.text = locationManager.coordinateAsString() ?? "unavailable"
		}
	}
	
    // MARK: -
    override func viewDidLoad() {
        addDismissKeyboardOnTapRecognizer(on: view)
        populate()
        if isReadOnly {
            navigationItem.rightBarButtonItem = nil
            uploadButton.isEnabled = false
            uploadButton.alpha = 0
            uploadLabel.alpha = 0
            captionTextView.isEditable = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObservers()
    }

	// MARK: -
	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		if didMakeChange {
            let alert = UIAlertController(title: "Would you like to save data?", message: nil, yes: {
            }, cancel: {
                self.popViewController()
            })
            
			presentAlert(controller: alert)
		} else {
			popViewController()
		}
	}
    
    @IBAction fileprivate func photoTapped(_ sender: UIButton) {
        let alert = cameraOptionsController()
        presentAlert(controller: alert)
    }
    
	func keyboardWillShow(with height: NSNumber) {
		scrollView.contentInset.bottom = CGFloat(height.intValue + 40)
		scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
	}

	func keyboardWillHide() {
		scrollView.contentInset.bottom = 0
	}

	// MARK: -
	fileprivate func populate() {
        
		guard let photo = photo else { return }
		uploadButton.isEnabled = false
		uploadButton.alpha = 0
		uploadLabel.alpha = 0
		indicator.startAnimating()

        let url = URL(fileURLWithPath: FileManager.workDirectory.absoluteString).appendingPathComponent(photo.id, isDirectory: true)
        imageView.image = UIImage(contentsOfFile: url.path)
        
		captionTextView.text = photo.caption
		timestampLabel.text = photo.timestamp?.timeStampFormat()
		gpsLabel.text = photo.coordinate?.printableString()
		indicator.stopAnimating()
	}
    
    fileprivate func validate()->Bool {
        if imageView.image == nil {
            presentAlert(controller: Alerts.error)
            return false
        }
        return true
    }

    fileprivate func cameraOptionsController() -> UIAlertController {
        let alert   = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take Picture", style: .default, handler: { (_) in
            self.media(sourceType: .camera)
        })
        let library = UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            self.media(sourceType: .photoLibrary)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addActions([camera,library,cancel])
        return alert
    }
}

// MARK: -
extension UploadPhotoController: UITextViewDelegate {
    
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
		didMakeChange = true
		var length = textView.text?.count ?? 0
		length += text.count
		length -= range.length
		if length < 5000 {
			return true
		} else {
			presentAlert(title: "Text Limit Exceeded", message: "You've reached maximum number of characters allowed")
			return false
		}
	}
}

// MARK: -
extension UploadPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
			didMakeChange = true
			imageView.image = image
            uploadButton.alpha = 0.25
            uploadLabel.alpha = 0
			date = Date()
			location = locationManager.location
        }
		self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func media(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
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
