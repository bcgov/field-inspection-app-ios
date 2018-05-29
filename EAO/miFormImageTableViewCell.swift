//
//  miFormImageTableViewCell.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-12.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import UIKit

class miFormImageTableViewCell: BaseFormCell {

    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var container: UIView!

    var obj: SimpleCell? {
        didSet {
            self.imageContainer.image = obj?.image
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleContainer(view: container.layer)
        roundContainer(view: (imageView?.layer)!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(obj: SimpleCell) {
        self.obj = obj
    }
}
/*
 var obj: SimpleCell? {
 didSet {
 self.button.setTitle(obj?.title, for: .normal)
 }
 }

 var style: MiButtonStyle? {
 didSet{
 roundCorners = (style?.roundCorners)!
 buttonTitleColor = (style?.textColor)!
 containerBG = (style?.bgColor)!
 contentHeight = (style?.height)!
 }
 }

 var roundCorners: Bool = false {
 didSet{
 if roundCorners {
 roundContainer(view: button.layer)
 styleContainer(view: container.layer)
 }
 }
 }

 var buttonTitleColor: UIColor = UIColor.white {
 didSet{
 self.button.setTitleColor(buttonTitleColor, for: .normal)
 }
 }

 var containerBG: UIColor = UIColor.blue {
 didSet{
 self.container.backgroundColor = containerBG
 }
 }

 var contentHeight: CGFloat = 40 {
 didSet{
 height.constant = contentHeight
 }
 }

 override func awakeFromNib() {
 super.awakeFromNib()
 NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: .miFormCallback, object: nil)
 }

 @objc func doThisWhenNotify() { return }

 override func setSelected(_ selected: Bool, animated: Bool) {
 super.setSelected(selected, animated: animated)
 }

 func setup(simpleCell: SimpleCell) {
 self.obj = simpleCell
 }

 @IBAction func clicked(_ sender: UIButton) {
 NotificationCenter.default.post(name: .miFormCallback, object: self, userInfo: ["name": self.obj?.name ?? "unknown"])
 }
 */

