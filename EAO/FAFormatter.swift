//
//  FAFormatter.swift
//  Field Insp
//
//  Created by Jason Leach on 2018-11-06.
//  Copyright © 2018 Province of British Columbia. All rights reserved.
//

import Foundation

enum FontAwesomeCharacter {
    case Cloud, CloudUpload, CloudDownload
    
    var unicodeCharacter: Character {
        switch self {
        case .Cloud: return "\u{f0c2}"
        case .CloudDownload: return "\u{f0ed}"
        case .CloudUpload: return "\u{f0ee}"
        }
    }
}

class FAFormatter {
    
    internal class func imageFrom(character: FontAwesomeCharacter, color: UIColor = Theme.governmentDarkBlue, size: CGFloat = 18.0, offset: CGFloat = 0.0) -> UIImage {
        
        let string = FAFormatter.attributedString(with: character, color: color, size: size, offset: offset)
        
        return imageFrom(string: string, size: CGSize(width: size, height: size))
    }
    
    private class func attributedString(with character: FontAwesomeCharacter, color: UIColor = Theme.governmentDarkBlue, size: CGFloat = 18.0, offset: CGFloat = 0.0) -> NSAttributedString {
        
        var attrs = baseAttributes()
        
        attrs[NSAttributedStringKey.font] = UIFont(name: "FontAwesome", size: size)!
        attrs[NSAttributedStringKey.baselineOffset] = Float(offset)
        attrs[NSAttributedStringKey.foregroundColor] = color
        
        return NSMutableAttributedString(string: "\(character.unicodeCharacter)", attributes:attrs)
    }

    private class func baseAttributes() -> [NSAttributedStringKey: Any] {
        
        let textLabelHeight: CGFloat = 18.0
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = textLabelHeight
        
        return [NSAttributedStringKey.paragraphStyle: paragraphStyle]
    }

    private class func imageFrom(string: NSAttributedString, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        string.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}
