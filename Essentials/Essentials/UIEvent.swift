//
//  UIEvent.swift
//  WineInsider
//
//  Created by Micha Volin on 2017-01-21.
//  Copyright © 2017 Spencer Mandrusiak. All rights reserved.
//

extension UIEvent {
    func point(in view: UIView) -> CGPoint? {
        return allTouches?.first?.location(in: view)
    }
}
