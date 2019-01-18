//
//  MainCell.swift
//  EAO
//
//  Created by Micha Volin on 2017-03-29.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

enum TransferState {
    case disabled
    case download
    case upload
}

final class InspectionCell: UITableViewCell {
    
    @IBOutlet internal var linkedProjectLabel: UILabel!
    @IBOutlet internal var titleLabel: UILabel!
    @IBOutlet internal var timeLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var transferButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet weak var disclosureIndicator: UIImageView!
    
    internal var onTransferTouched: (() -> Void)?
    
    override func awakeFromNib() {
        commonInit()
        
        transferButton.addTarget(self, action: #selector(InspectionCell.transferTouched), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        commonInit()
        
        onTransferTouched = nil
    }
    
    private func commonInit() {

        configForTransferState(state: .disabled)
        enableEdit(canEdit: false)
        uploadInProgress(isUploading: false)

        let img = FAFormatter.imageFrom(character: .Edit, color: Theme.governmentDarkBlue, size: 90.0, offset: 2.0)
        editButton.setBackgroundImage(img, for: .normal)
        editButton.backgroundColor = UIColor.white
        transferButton.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        disclosureIndicator.isHidden = true
        indicator.color = Theme.governmentDeepYellow
    }
    
    @objc dynamic private func transferTouched(sender: UIButton!) {
        onTransferTouched?()
    }
    
    // MARK: States
    
    func configureCell(with inspection: Inspection) {
        
        var date = ""
        
        if let start = inspection.start {
            date = start.inspectionFormat()
        }
        
        if let end = inspection.end {
            date += " - \(end.inspectionFormat())"
        }
        
        titleLabel.text = inspection.title
        timeLabel.text = date
        linkedProjectLabel.text = inspection.project

        if inspection.isSubmitted == false {
            enableEdit(canEdit: true)
            configForTransferState(state: .upload)
        } else if inspection.isSubmitted && inspection.isStoredLocally {
            configForTransferState(state: .disabled)
            enableEdit(canEdit: false)
        } else if inspection.isSubmitted && inspection.isStoredLocally == false {
            configForTransferState(state: .download)
        } else {
            configForTransferState(state: .upload)
        }
    }
    
    internal func enableEdit(canEdit value: Bool) {
        if value {
            editButton.isHidden = false
            return
        }
        
        editButton.isHidden = true
    }
    
    internal func configForTransferState(state: TransferState) {
        
        switch state {
        case .disabled:
            transferButton.isHidden = true
            indicator.stopAnimating()
            disclosureIndicator.isHidden = false
            
        case .download:
            transferButton.isHidden = false
            disclosureIndicator.isHidden = true
            let img = FAFormatter.imageFrom(character: .CloudDownload, color: Theme.governmentDarkBlue, size: 90.0, offset: 2.0)
            transferButton.setBackgroundImage(img, for: .normal)
            indicator.stopAnimating()
            
        case .upload:
            transferButton.isHidden = false
            disclosureIndicator.isHidden = true
            let img = FAFormatter.imageFrom(character: .CloudUpload, color: Theme.governmentDarkBlue, size: 90.0, offset: 2.0)
            transferButton.setBackgroundImage(img, for: .normal)
            indicator.stopAnimating()
        }
    }

    internal func uploadInProgress(isUploading value: Bool) {
        configForTransferState(state: .disabled)

        if value {
            indicator.startAnimating()
//            progressBar.isHidden = false
            return
        }
        
        indicator.stopAnimating()
//        progressBar.isHidden = true
    }
}
