//
//  ObservationElementPhotoCell.swift
//  EAO
//
//  Created by Micha Volin on 2017-05-15.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

final class ObservationElementPhotoCell: UICollectionViewCell {
    
	@IBOutlet private var imageView: UIImageView!
	@objc func setData(image: UIImage?) {
		imageView.image = image
	}
}
