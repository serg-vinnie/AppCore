//
//  String.swift
//  KeyKey
//
//  Created by Loki on 2/24/17.
//  Copyright © 2017 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public extension String {
    
    subscript (i: Int) -> String {
        get {
            return self[i ..< i + 1]
        }
        set (value) {
            let range = index(startIndex, offsetBy: i) ..< index(startIndex, offsetBy: i+1)
            self.replaceSubrange(range, with : value)
        }
    }
    
    func substring(from: Int) -> String {
        return self[min(from, count) ..< count]
    }
    
    func substring(to: Int) -> String {
        return self[0 ..< max(0, to)]
    }
    
    subscript (r: Range<Int>) -> String {
        get {
            let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                                upper: min(count, max(0, r.upperBound))))
            let start = index(startIndex, offsetBy: range.lowerBound)
            let end = index(start, offsetBy: range.upperBound - range.lowerBound)
            return String(self[start ..< end])
        }
        set (value) {
            let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                                upper: min(count, max(0, r.upperBound))))
            let start = index(startIndex, offsetBy: range.lowerBound)
            let end = index(start, offsetBy: range.upperBound - range.lowerBound)
            
            self.replaceSubrange(start ..< end, with : value)
        }
    }
    
    subscript (nsrange: NSRange) -> String {
        get {
            if let range = Range(nsrange, in: self) {
                return String(self[range])
            } else {
                return ""
            }
        }

        set {
            if let range = Range(nsrange, in: self) {
                self.replaceSubrange(range, with: newValue)
            }
        }
    }
    
    func indexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
    
    ///  Created by DragonCherry on 5/11/17.
    /// Inner comparison utility to handle same versions with different length. (Ex: "1.0.0" & "1.0")
    private func compare(toVersion targetVersion: String) -> ComparisonResult {
        
        let versionDelimiter = "."
        var result: ComparisonResult = .orderedSame
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
        let spareCount = versionComponents.count - targetComponents.count
        
        if spareCount == 0 {
            result = compare(targetVersion, options: .numeric)
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                targetComponents.append(contentsOf: spareZeros)
            } else {
                versionComponents.append(contentsOf: spareZeros)
            }
            result = versionComponents.joined(separator: versionDelimiter)
                .compare(targetComponents.joined(separator: versionDelimiter), options: .numeric)
        }
        return result
    }
    
    func isVersion(equalTo targetVersion: String)              -> Bool { return compare(toVersion: targetVersion) == .orderedSame }
    func isVersion(greaterThan targetVersion: String)          -> Bool { return compare(toVersion: targetVersion) == .orderedDescending }
    func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedAscending }
    func isVersion(lessThan targetVersion: String)             -> Bool { return compare(toVersion: targetVersion) == .orderedAscending }
    func isVersion(lessThanOrEqualTo targetVersion: String)    -> Bool { return compare(toVersion: targetVersion) != .orderedDescending }

    
    func isEmail() -> Bool {
        let firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstpart + "@" + serverpart + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: self)
    }
    
    func withReplacing(from: String, to: String) -> String {
        return replacingOccurrences(of: from, with: to, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func extractRegExp(pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(location: 0, length: utf16.count)
        
        if let result = regex.firstMatch(in: self, options: [], range: range) {
            return self[result.range]
        }
        
        return nil
    }
}
