//
//  MiFormTextViewTableViewCell.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-12.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import UIKit

class MiFormTextViewTableViewCell: BaseFormCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!

    var obj: SimpleCell? {
        didSet {
            self.titleLabel.text = (obj?.title)!
            self.textView.keyboardType = (obj?.keyboardType)!
        }
    }

    var style: MiTextFieldStyle? {
        didSet{
            fieldHeight = (style?.height)!
            roundCorners = (style?.roundCorners)!
            inputColor = (style?.inputColor)!
            bgColor = (style?.bgColor)!
            titleColor = (style?.titleColor)!
            inputBG = (style?.fieldBG)!
        }
    }

    var fieldHeight: CGFloat = 250 {
        didSet{
            self.textViewHeight.constant = fieldHeight
        }
    }

    var roundCorners: Bool = false {
        didSet{
            if roundCorners {
                roundContainer(view: textView.layer)
                styleContainer(view: container.layer)
            }
        }
    }

    var inputColor: UIColor = UIColor.black {
        didSet{
            textView.textColor = inputColor
        }
    }

    var inputBG: UIColor = UIColor.white {
        didSet{
            textView.backgroundColor = inputBG
            textView.layer.borderColor = inputBG.cgColor
        }
    }

    var bgColor: UIColor = UIColor.white {
        didSet{
            container.backgroundColor = bgColor
        }
    }

    var titleColor: UIColor = UIColor.black {
        didSet{
            titleLabel.textColor = titleColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(obj: SimpleCell) {
        self.obj = obj
        if obj.currValue != "" && obj.currValue != textView.text {
            textView.text = ""
        }
    }
}

extension MiFormTextViewTableViewCell: UITextViewDelegate {
    //    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //        let vc = self.parentViewController as? MiFormViewController
    //        let textString = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
    //        vc?.results[(self.obj?.name)!] = textString
    //        return true
    //    }

    func textViewDidChange(_ textView: UITextView) {
        //        let vc = self.parentViewController as? MiFormViewController
        //        let textString = NSString(string: textView.text!)
        self.obj?.currValue = textView.text!
        //        vc?.results[(self.obj?.name)!] = textString
    }
}


/*
 var obj: SimpleCell? {
 didSet {
 self.titleLabel.text = (obj?.title)!
 self.inputField.placeholder = (obj?.placeholder)!
 self.inputField.keyboardType = (obj?.keyboardType)!
 }
 }

 var style: MiTextFieldStyle? {
 didSet{
 fieldHeight = (style?.height)!
 roundCorners = (style?.roundCorners)!
 inputColor = (style?.inputColor)!
 bgColor = (style?.bgColor)!
 titleColor = (style?.titleColor)!
 inputBG = (style?.fieldBG)!
 borderStyle = (style?.borderStyle)!
 }
 }

 var fieldHeight: CGFloat = 100 {
 didSet{
 height.constant = fieldHeight
 }
 }

 var roundCorners: Bool = false {
 didSet{
 if roundCorners {
 roundContainer(view: inputField.layer)
 styleContainer(view: container.layer)
 }
 }
 }
 //inputColor: UIColor,fieldBG: UIColor, bgColor: UIColor, height: CGFloat, roundCorners: Bool

 var inputColor: UIColor = UIColor.black {
 didSet{
 inputField.textColor = inputColor
 }
 }

 var inputBG: UIColor = UIColor.white {
 didSet{
 inputField.backgroundColor = inputBG
 inputField.layer.borderColor = inputBG.cgColor
 }
 }

 var bgColor: UIColor = UIColor.white {
 didSet{
 container.backgroundColor = bgColor
 }
 }

 var titleColor: UIColor = UIColor.black {
 didSet{
 titleLabel.textColor = titleColor
 }
 }

 var borderStyle = UITextBorderStyle.roundedRect {
 didSet{
 inputField.borderStyle = borderStyle
 }
 }

 override func awakeFromNib() {
 super.awakeFromNib()
 inputField.delegate = self
 }

 override func setSelected(_ selected: Bool, animated: Bool) {
 super.setSelected(selected, animated: animated)
 }

 func setup(obj: SimpleCell, shouldReset: Bool) {
 self.obj = obj
 if shouldReset {reset()}
 }

 func reset() {
 let vc = self.parentViewController as? MiFormViewController
 vc?.results.removeValue(forKey: (self.obj?.name)!)
 self.inputField.text = ""
 }
 }

 extension SimpleFormTableViewCell: UITextFieldDelegate {
 func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
 let vc = self.parentViewController as? MiFormViewController
 let textString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
 vc?.results[(self.obj?.name)!] = textString
 return true
 }
 }

 */

