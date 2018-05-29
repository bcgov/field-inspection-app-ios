//
//  UIImage.swift
//  EAO
//
//  Created by Work on 2017-02-21.
//  Copyright © 2017 FreshWorks. All rights reserved.
//

import UIKit

extension UIImage {
    @objc convenience init?(fromColor color: UIColor) {
        let frame = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContext(frame.size)

        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(frame)

        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        guard let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
