//
//  MiFormButtonTableViewCell.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let miFormCallback =  Notification.Name("miFormCallback")
}

class MiFormButtonTableViewCell: BaseFormCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var height: NSLayoutConstraint!

    var obj: SimpleCell? {
        didSet {
            self.button.setTitle(obj?.title, for: .normal)
        }
    }

    var style: MiButtonStyle? {
        didSet {
            roundCorners = (style?.roundCorners)!
            buttonTitleColor = (style?.textColor)!
            containerBG = (style?.bgColor)!
            contentHeight = (style?.height)!
        }
    }

    var roundCorners: Bool = false {
        didSet {
            if roundCorners {
                roundContainer(view: button.layer)
                styleContainer(view: container.layer)
            }
        }
    }

    var buttonTitleColor: UIColor = UIColor.white {
        didSet {
            self.button.setTitleColor(buttonTitleColor, for: .normal)
        }
    }

    var containerBG: UIColor = UIColor.blue {
        didSet {
            self.container.backgroundColor = containerBG
        }
    }

    var contentHeight: CGFloat = 40 {
        didSet {
            height.constant = contentHeight
        }
    }

    @objc func formCallbackAction() {
        return
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(formCallbackAction), name: .miFormCallback, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(simpleCell: SimpleCell) {
        self.obj = simpleCell
    }

    @IBAction func clicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: .miFormCallback, object: self, userInfo: ["name": self.obj?.name ?? "unknown"])
    }
}

