//
//  DescriptionNewObservationCollectionViewCell.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-16.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit

class DescriptionNewObservationCollectionViewCell: BaseCollectionCell {

    // Constraints
    @IBOutlet weak var cellHeight: NSLayoutConstraint!

    // Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var fieldNameContainer: UIView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        styleContainer(view: container.layer)
        roundContainer(view: fieldNameContainer.layer)
        label.textColor = UIColor(hex: "cddfff")
    }

    func setup(text: String) {
        textView.text = text
    }
}

