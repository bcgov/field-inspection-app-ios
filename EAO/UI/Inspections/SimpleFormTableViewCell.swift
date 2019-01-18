//
//  SimpleFormTableViewCell.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import UIKit

class SimpleFormTableViewCell: BaseFormCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var height: NSLayoutConstraint!

    var obj: SimpleCell? {
        didSet {
            self.titleLabel.text = (obj?.title)!
            self.inputField.placeholder = (obj?.placeholder)!
            self.inputField.keyboardType = (obj?.keyboardType)!
            self.inputField.text = obj?.currValue
            self.inputField.isSecureTextEntry = (obj?.isSecureTextEntry)!
        }
    }

    var style: MiTextFieldStyle? {
        didSet {
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
        didSet {
            height.constant = fieldHeight
        }
    }

    var roundCorners: Bool = false {
        didSet {
            if roundCorners {
                roundContainer(view: inputField.layer)
                styleContainer(view: container.layer)
            }
        }
    }
    //inputColor: UIColor,fieldBG: UIColor, bgColor: UIColor, height: CGFloat, roundCorners: Bool

    var inputColor: UIColor = UIColor.black {
        didSet {
            inputField.textColor = inputColor
        }
    }

    var inputBG: UIColor = UIColor.white {
        didSet {
            inputField.backgroundColor = inputBG
            inputField.layer.borderColor = inputBG.cgColor
        }
    }

    var bgColor: UIColor = UIColor.white {
        didSet {
            container.backgroundColor = bgColor
        }
    }

    var titleColor: UIColor = UIColor.black {
        didSet {
            titleLabel.textColor = titleColor
        }
    }

    var borderStyle = UITextField.BorderStyle.roundedRect {
        didSet {
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

    func setup(obj: SimpleCell) {
        self.obj = obj
        if obj.currValue.count > 0 && inputField.text != obj.currValue {
            inputField.text = ""
        }
    }
}

extension SimpleFormTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        self.obj?.currValue = textString
        return true
    }
}

