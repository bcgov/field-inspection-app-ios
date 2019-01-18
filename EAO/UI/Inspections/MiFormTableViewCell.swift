//
//  MiFormTableViewCell.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-16.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import UIKit

class MiFormTableViewCell: BaseFormCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var height: NSLayoutConstraint!

    var obj: SimpleCell? {
        didSet {
            self.label.text = obj?.title
        }
    }

    var bgColor: UIColor = UIColor.white {
        didSet {
            self.container.backgroundColor = bgColor
        }
    }

    var fieldHeight: CGFloat = 80 {
        didSet {
            height.constant = fieldHeight
        }
    }

    var roundCorners: Bool = false {
        didSet {
            if roundCorners {
                roundContainer(view: label.layer)
                styleContainer(view: container.layer)
            }
        }
    }

    var style: LabelStyle? {
        didSet {
            fieldHeight = (style?.height)!
            roundCorners = (style?.roundCorners)!
            bgColor = (style?.bgColor)!
            labelTextColor = (style?.labelTextColor)!
        }
    }

    var labelTextColor: UIColor = UIColor.black {
        didSet {
            label.textColor = labelTextColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if self.label.text == "" {
            self.container.isHidden = true
            self.roundCorners = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(obj: SimpleCell) {
        self.obj = obj
    }
}
