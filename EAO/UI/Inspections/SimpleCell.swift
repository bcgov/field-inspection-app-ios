//
//  SimpleCell.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class SimpleCell {

    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    // have at least one uppercase, at least a number, and a minimum length of 6 characters and a maximum of 15
    let passwordRegex = "(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,15}"
    let phoneRegex = "[0-9]{10}"

    var name: String = ""
    var title: String = ""
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = UIKeyboardType.alphabet
    var type: SimpleCellType?
    var isSecureTextEntry = false
    var completion: (() -> Void)?

    var buttonStyle: MiButtonStyle?

    var textfieldStyle: MiTextFieldStyle?
    var textFieldInvalidStyle: MiTextFieldStyle?
    var labelStyle: LabelStyle?

    var isOptional: Bool = false
    var regEx: String?
    var inputType: FormInputType?

    var currValue: String = "" {
        didSet {
            self.isValid = isValueValid()
        }
    }

    var expectedValue: String?
    var isValid: Bool = false
    var image: UIImage?

    init(name: String, title: String, placeholder: String, type: SimpleCellType, inputType: FormInputType) {
        self.name = name
        self.title = title
        self.placeholder = placeholder
        self.type = type
        self.inputType = inputType
        setInputType()
        if inputType == .Password {
            self.isSecureTextEntry = true
        }
    }

    init(name: String, title: String, type: SimpleCellType) {
        self.name = name
        self.title = title
        self.type = type
    }

    init(image: UIImage) {
        self.type = SimpleCellType.Image
        self.image = image
    }

    init(name: String, text: String) {
        self.type = SimpleCellType.Label
        self.title = text
        self.name = name
    }

    func setInputType() {
        switch inputType {
        case .Text?:
            keyboardType = .alphabet
        case .Number?:
            keyboardType = .numberPad
        case .Email?:
            keyboardType = .emailAddress
            regEx = emailRegEx
        case .Password?:
            keyboardType = .alphabet
            isSecureTextEntry = true
            regEx = passwordRegex
        case .Phone?:
            keyboardType = .numberPad
            regEx = phoneRegex
        default:
            keyboardType = .alphabet
        }
    }

    func isValueValid() -> Bool {
        if !evaluateRegex() {
            return false
        }

        if expectedValue != nil {
            return currValue == expectedValue
        } else if !isOptional {
           return currValue != ""
        } else {
            return true
        }
    }

    func evaluateRegex() -> Bool {
        if regEx == nil {
            return true
        }
        let pred = NSPredicate(format: "SELF MATCHES[c] %@", regEx!)
        return pred.evaluate(with: currValue)
    }

    func reValidate() {
        self.isValid = isValueValid()
    }
}

enum SimpleCellType {
    case Button
    case TextInput
    case TextViewInput
    case Image
    case Label
}

enum FormInputType {
    case Email
    case Password
    case Phone
    case Number
    case Text
}

