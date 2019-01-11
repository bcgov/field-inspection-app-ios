//
//  ImageCollectionViewCell.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-17.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit
import Photos

enum MediaCellType {
    case Audio
    case PHAsset
    case Thumbnail
}
class ImageCollectionViewCell: BaseCollectionCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var type: MediaCellType?
    var audio: Audio?
    var setting: Bool = false
    var asset: PHAsset?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleContainer(view: container.layer)
        roundContainer(view: imageView.layer)
        imageView.clipsToBounds = true
    }
    func setWithAsset(asset: PHAsset, type: MediaCellType) {
        self.type = type
        self.asset = asset
        DispatchQueue.main.async {
            AssetManager.sharedInstance.getImageFromAsset(phAsset: asset) { (image) in
                if self.type == .PHAsset && self.asset == asset {
                    self.imageView.image = image
                }
            }
        }
    }

    func setWithPFThumb(photo: PhotoThumb, type: MediaCellType) {
        self.type = type
        guard let img = photo.image else { return}
        imageView.image = img
    }

    func setAudio(audio: Audio, type: MediaCellType) {
        self.type = type
        self.imageView.image = #imageLiteral(resourceName: "soundPlaceHolder")
        self.audio = audio
    }
}
