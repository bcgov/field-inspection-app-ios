//
//  MiFormManager.swift
//  time-me
//
//  Created by Amir Shayegh on 2018-01-08.
//  Copyright © 2018 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class MiFormManager {
    
    lazy var miForm: MiFormViewController = {
        return UIStoryboard(name: "MiForm", bundle: Bundle.main).instantiateViewController(withIdentifier: "MiForm") as! MiFormViewController
    }()
    
    var fields = [SimpleCell]() {
        didSet {
            miForm.fields = fields
        }
    }
    
    init () {
        NotificationCenter.default.addObserver(forName: .miFormCallback, object: nil, queue: nil, using: catchAction)
    }
    
    func close() {
        miForm.close {
            self.fields.removeAll()
            self.miForm.fields.removeAll()
        }
    }
    
    func catchAction(notification: Notification) {
        guard let name = notification.userInfo!["name"] else { return }
        let field = fieldNamed(name: name as! String)
        if field.name == name as! String && field.type == .Button {
            return field.completion!()
        }
    }
    
    // MARK: - Setters
    
    func addField(name: String, title: String, placeholder: String, expectedValue: String? = nil, isOptional: Bool? = false, type: SimpleCellType, inputType: FormInputType,style: MiTextFieldStyle? = nil, styleInvalid: MiTextFieldStyle? = nil) {
        let field = SimpleCell(name: name, title: title, placeholder: placeholder, type: type, inputType: inputType)
        field.textfieldStyle = style
        field.textFieldInvalidStyle = styleInvalid
        field.expectedValue = expectedValue
        field.isOptional = isOptional!
        fields.append(field)
    }
    
    func addButton(name: String, title: String, style: MiButtonStyle? = nil, completion: @escaping () -> Void) {
        let button = SimpleCell(name: name, title: title, type: .Button)
        button.completion = completion
        button.buttonStyle = style
        fields.append(button)
    }
    
    func addImage(image: UIImage) {
        fields.append(SimpleCell(image: image))
    }
    
    func setBG(color: UIColor) {
        miForm.bg = color
    }
    
    func addLabel(name: String, text: String, style: LabelStyle? = nil) {
        let label = SimpleCell(name: name, text: text)
        label.labelStyle = style
        fields.append(label)
    }
    
    // MARK: - Editing fields
    func editFieldTitle(named: String, title: String) {
        let i = indexOfField(named: named)
        fields[i].title = title
        miForm.tableView.reloadData()
    }
    
    func editFieldStyle(named: String, style: MiTextFieldStyle) {
        let i = indexOfField(named: named)
        fields[i].textfieldStyle = style
        miForm.tableView.reloadData()
    }
    
    func editLabelText(name: String, newText: String) {
        let i = indexOfField(named: name)
        fields[i].title = newText
        miForm.tableView.reloadData()
    }
    
    // MARK: - Validation
    func validateAuto() -> Bool {
        var valid = true
        let fields = getFormElements()
        var p1: String? = nil
        for field in fields {
            if field.type != SimpleCellType.TextInput {
                continue
            } else {
                field.reValidate()
                if field.name.lowercased() == "password" {
                    p1 = field.currValue
                }
                if p1 != nil {
                    if field.name.lowercased() == "password2" {
                        if field.currValue != p1 {
                            valid = false
                        }
                    }
                }
                if !field.isValid {
                    valid = false
                    editFieldStyle(named: field.name, style: field.textFieldInvalidStyle!)
                } else {
                    editFieldStyle(named: field.name, style: field.textfieldStyle!)
                }
            }
        }
        return valid
    }
    func validate(validStyle: MiTextFieldStyle, invalidStyle: MiTextFieldStyle) -> Bool {
        var valid = true
        let fields = getFormElements()
        let results = getFormResults()
        
        for field in fields {
            if field.type != SimpleCellType.TextInput {
                continue
            } else {
                field.reValidate()
                if field.name.lowercased() == "password2" {
                    let p1: String = results["password"]!
                    let p2: String = results["password2"]!
                    valid = p1 == p2
                }
                
                if !field.isValid {
                    valid = false
                    editFieldStyle(named: field.name, style: invalidStyle)
                } else {
                    editFieldStyle(named: field.name, style: validStyle)
                }
            }
        }
        return valid
    }
    
    // MARK: - Getters
    func getFormResults() -> [String: String] {
        var rsp = [String: String]()
        for element in miForm.fields {
            if element.type == SimpleCellType.TextInput || element.type == SimpleCellType.TextViewInput {
                rsp[element.name] = element.currValue
            }
        }
        return rsp
    }
    
    // careful with optional fields..
    func getResultFor(name: String) -> String {
        let all = getFormResults()
        let r = all[name]
        return r!
    }
    
    func getFormElements() -> [SimpleCell] {
        return miForm.fields
    }
    
    func getForm() -> UIViewController {
        return miForm
    }
    
    func getDefaultButtonStyle() -> MiButtonStyle {
        return MiButtonStyle(textColor: .white, bgColor: .purple, height: 50, roundCorners: true)
    }
    
    func getDefaultTextFieldStyle() -> MiTextFieldStyle {
        let commonFieldStyle = MiTextFieldStyle(titleColor: .purple, inputColor: .purple, fieldBG: .white, bgColor: .white, height: 70, roundCorners: true)
        commonFieldStyle.borderStyle = UITextField.BorderStyle.none
        return commonFieldStyle
    }
    
    func getDefaultTextFieldStyleERROR() -> MiTextFieldStyle {
        let commonFieldStyleError = MiTextFieldStyle(titleColor: .white, inputColor: .purple, fieldBG: .white, bgColor: .red, height: 70, roundCorners: true)
        commonFieldStyleError.borderStyle = UITextField.BorderStyle.none
        return commonFieldStyleError
    }
    
    func getDefaultTextViewStyle() -> MiTextFieldStyle {
        let commonTextViewStyle = MiTextFieldStyle(titleColor: .purple, inputColor: .purple, fieldBG: .white, bgColor: .white, height: 300, roundCorners: true)
        commonTextViewStyle.borderStyle = UITextField.BorderStyle.none
        return commonTextViewStyle
    }
    
    // MARK: - Displaying form in a container
    
    func display(in container: UIView, on viewController: UIViewController) {
        let subs = container.subviews
        for sub in subs {
            sub.removeFromSuperview()
        }
        container.alpha = 1
        viewController.addChild(miForm)
        container.addSubview(miForm.view)
        miForm.view.frame = container.bounds
        miForm.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        miForm.didMove(toParent: viewController)
    }
    
    /**
     Note: also hides container by setting alpha to 0
     */
    func remove(from container: UIView, then hide: Bool? = true) {
        miForm.willMove(toParent: nil)
        miForm.view.removeFromSuperview()
        miForm.removeFromParent()
        if hide! {
            container.alpha = 0
        }
    }
    
    // MARK: - Helper functions
    
    // MARK: : BROKEN
    func clear() {
        for field in miForm.fields {
            field.currValue = ""
        }
        miForm.tableView.reloadData()
    }
    
    // MARK: : BROKEN
    func clear(with style: MiTextFieldStyle) {
        for field in miForm.fields {
            if field.type == SimpleCellType.TextInput || field.type == SimpleCellType.TextViewInput {
                field.textfieldStyle = style
                field.currValue = ""
            }
        }
        miForm.tableView.reloadData()
    }
    
    // Locally used Utilities
    
    /**
     Should be improved
     */
    private func fieldNamed(name: String) -> SimpleCell {
        var returnfield = SimpleCell(name: "nil", title: "", placeholder: "", type: .TextInput, inputType: .Text)
        for field in fields {
            if field.name == name {
                returnfield = field
                break
            }
        }
        return returnfield
    }
    
    private func indexOfField(named: String) -> Int {
        let x = fields.index { (field) -> Bool in
            field.name == named
        }
        return x!
    }
}

