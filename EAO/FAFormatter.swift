//
//  FAFormatter.swift
//  Field Insp
//
//  Created by Jason Leach on 2018-11-06.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import Foundation

enum FontAwesomeCharacter {
    case Cloud, CloudUpload, CloudDownload, Edit, GreaterThan
    
    var unicodeCharacter: Character {
        switch self {
        case .Cloud: return "\u{f0c2}"
        case .CloudDownload: return "\u{f0ed}"
        case .CloudUpload: return "\u{f0ee}"
        case .Edit: return "\u{f044}"
        case .GreaterThan: return "\u{f531}"
        }
    }
}

class FAFormatter {
    
    internal class func imageFrom(character: FontAwesomeCharacter, color: UIColor = Theme.governmentDarkBlue, size: CGFloat = 18.0, offset: CGFloat = 0.0) -> UIImage {
        
        let string = FAFormatter.attributedString(with: character, color: color, size: size)
        
        let image = imageFrom(string: string)
        let scaledImage = scale(image: image, toWidth: size, verticalOffset: offset)
        
        return scaledImage
    }
    
    private class func attributedString(with character: FontAwesomeCharacter, color: UIColor = Theme.governmentDarkBlue, size: CGFloat = 18.0) -> NSAttributedString {
        
        var attrs = baseAttributes()
        
        attrs[NSAttributedString.Key.font] = UIFont(name: "FontAwesome", size: size)!
//        attrs[NSAttributedStringKey.baselineOffset] = Float(offset)
        attrs[NSAttributedString.Key.foregroundColor] = color

        return NSMutableAttributedString(string: "\(character.unicodeCharacter)", attributes: attrs)
    }

    private class func baseAttributes() -> [NSAttributedString.Key: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }

    private class func imageFrom(string: NSAttributedString) -> UIImage {
        
        let xmax = max(string.size().width, string.size().height)
        let size = CGSize(width: xmax, height: xmax)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        string.draw(at: CGPoint.zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        return image!
    }
    
    private class func scale(image: UIImage, toWidth width: CGFloat, verticalOffset: CGFloat = 0) -> UIImage {
    
        let size = CGSize(width: width, height: width)

        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        image.draw(in: CGRect(x: 0.0, y: verticalOffset, width: width, height: width))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}
