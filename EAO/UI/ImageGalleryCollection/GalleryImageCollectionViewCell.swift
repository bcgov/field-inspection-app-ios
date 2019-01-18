//
//  GalleryImageCollectionViewCell.swift
//  imageMultiSelect
//
//  Created by Amir Shayegh on 2017-12-12.
//  Copyright © 2017 Amir Shayegh. All rights reserved.
//

import UIKit
import Photos

class GalleryImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isSelectedLabel: UILabel!
    @IBOutlet weak var isSelectedView: UIView!

    var asset: PHAsset?

    var cellSelected: Bool = true {
        didSet {
            if cellSelected {select()} else {deSelect()}
        }
    }

    func select() {
        self.isSelectedLabel.isHidden = false
        self.isSelectedView.isHidden = false
    }

    func deSelect() {
        self.isSelectedLabel.isHidden = true
        self.isSelectedView.isHidden = true
    }

    func selectCell(index: Int) {
        self.isSelectedLabel.text = "\(index + 1)"
        cellSelected = true
    }

    func setUp(selectedIndexes: [Int], indexPath: IndexPath, phAsset: PHAsset, primaryColor: UIColor, textColor: UIColor) {
        style()
        self.cellSelected = false
        self.deSelect()
        self.isSelectedLabel.text = ""
        
        if selectedIndexes.contains(indexPath.row) {
            if let index = selectedIndexes.index(of: indexPath.row) {
                selectCell(index: index)
            }
        }

        AssetManager.sharedInstance.getImageFromAsset(phAsset: phAsset) { (assetImage) in
            self.imageView.image = assetImage
        }
    }

    func style() {
        imageView.clipsToBounds = true
        isSelectedView.backgroundColor = UIColor(hex: "4667a2")
        isSelectedLabel.textColor = UIColor.white
        isSelectedLabel.alpha = 0.8
        isSelectedView.layer.cornerRadius = isSelectedView.frame.height/2
        imageView.layer.borderColor = UIColor(hex: "4667a2").cgColor
        imageView.layer.borderWidth = 2
        styleContainer(view: container.layer)
        roundContainer(view: imageView.layer)
    }

    func styleContainer(view: CALayer) {
        roundContainer(view: view)
        view.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOffset = CGSize(width: 0, height: 2)
        view.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.shadowOpacity = 1
        view.shadowRadius = 3
    }

    func roundContainer(view: CALayer) {
        view.cornerRadius = 8
    }
}
