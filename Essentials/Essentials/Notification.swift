//
//  notification.swift
//  WineInsider
//
//  Created by Micha Volin on 2017-01-31.
//  Copyright © 2017 Spencer Mandrusiak. All rights reserved.
//
extension Notification {
   
    public var keyboardHeight: CGFloat? {
        return (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
    }
    
    public static func post(name: String, _ object: AnyObject?=nil) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
    }
}
