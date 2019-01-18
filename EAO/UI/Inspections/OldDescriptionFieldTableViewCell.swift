//
//  OldDescriptionFieldTableViewCell.swift
//  EAO
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 FreshWorks. All rights reserved.
//

import UIKit

class OldDescriptionFieldTableViewCell: BaseFormCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var topContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        styleContainer(view: container.layer)
        roundContainer(view: topContainer.layer)
        topContainer.backgroundColor = UIColor(hex: "4667a2")
        label.textColor = UIColor(hex: "cddfff")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUp(text: String) {
        textView.text = text
    }

    func hide() {
        height.constant = 0
    }
}
