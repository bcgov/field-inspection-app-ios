//
//  MainCell.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-29.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

final class InspectionCell: UITableViewCell{
	@IBOutlet fileprivate var linkedProjectLabel: UILabel!
	@IBOutlet fileprivate var titleLabel : UILabel!
	@IBOutlet fileprivate var timeLabel  : UILabel!
	@IBOutlet fileprivate var editButton : UIButton!
	@IBOutlet fileprivate var uploadButton: UIButton!
	@IBOutlet fileprivate var progressBar: UIProgressView!
	@IBOutlet fileprivate var indicator: UIActivityIndicatorView!
	
	@objc func setData(title: String?,time: String?, isReadOnly: Bool, progress: Float, isBeingUploaded: Bool, isEnabled: Bool, linkedProject: String?){
		titleLabel.text = title
		timeLabel.text  = time
		linkedProjectLabel.text = linkedProject
		progressBar.progress = progress
		if isReadOnly{
			indicator.stopAnimating()
			progressBar.isHidden = true
			editButton.isHidden = true
			uploadButton.isUserInteractionEnabled = false
			uploadButton.setBackgroundImage(#imageLiteral(resourceName: "icon_eye_blue"), for: .normal)
			if isBeingUploaded{
				uploadButton.isHidden = true
			} else{
				uploadButton.isHidden = false
			}
		} else{
			if isBeingUploaded{
				uploadButton.isHidden = true
				progressBar.isHidden = false
				indicator.startAnimating()
			} else{
				uploadButton.isHidden = false 
				progressBar.isHidden = true
				indicator.stopAnimating()
			}
			editButton.isHidden = false
			uploadButton.isUserInteractionEnabled = !isEnabled
			uploadButton.setBackgroundImage(#imageLiteral(resourceName: "icon_upload"), for: .normal)
		}
	}
}




