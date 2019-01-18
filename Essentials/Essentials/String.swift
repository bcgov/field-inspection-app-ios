//
//  String.swift
//  Vmee
//
//  Created by Micha Volin on 2016-12-15.
//  Copyright © 2016 Vmee. All rights reserved.
//

extension String {
    
    static public func random() -> String {
        let number = arc4random_uniform(999999999)
        return "\(number)"
    }
    
    public func isEmpty() -> Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    public func firstComponent() -> String {
        if let component = self.components(separatedBy: " ").first {
            return component
        }
        
        return self
    }
    
    public func trimBy(numberOfChar: Int) -> String {
        return String(self.dropFirst(numberOfChar))
    }
    
    public func trimWhiteSpace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func boolean() -> Bool? {
        return NSString(string: self).boolValue
    }
    
    ///Bigger score indicates better result
    public func map(to search: String) -> Int {
        var scrore = 0
        let search = Array(search.lowercased())
        let str = Array(self.lowercased())
        for (index, char) in str.enumerated() {
            if search.count > index {
                if search[index] == char {
                    scrore += 1
                }
            }
        }
        return scrore
    }
    
    ///Returns number of edits required to make both strings same
    public func compare(to string: String) -> Int? {
        if self == "" || string == ""{
            return nil
        }
        let a = Array(self.lowercased())
        let b = Array(string.lowercased())
        
        var dist = [[Int]]()
        
        for _ in 0...a.count {
            dist.append([Int](repeating: 0, count: b.count + 1))
        }
        
        for i in 1...a.count {
            dist[i][0] = i
        }
        
        for j in 1...b.count {
            dist[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i][j] = dist[i-1][j-1]
                } else {
                    dist[i][j] = Swift.min(
                        dist[i-1][j] + 1,
                        dist[i][j-1] + 1,
                        dist[i-1][j-1] + 1
                    )
                }
            }
        }
        return dist[a.count][b.count]
    }
    
    public func ranges(of substring: String) -> [NSRange] {
        var result: [NSRange] = []
        var start = startIndex
        while let range = range(of: substring, options: .caseInsensitive, range: start..<endIndex) {
            let location = distance(from: start, to: range.lowerBound)
            let lenght = distance(from: range.lowerBound, to: range.upperBound)
            result.append(NSRange.init(location: location, length: lenght))
            start = range.upperBound
        }
        return result
    }
}

extension String {
    public func height(for width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: font], context: nil)
        return actualSize.height
    }
}
