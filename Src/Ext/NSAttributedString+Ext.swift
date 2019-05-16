//
//  NSAttributedString+Ext.swift
//  AppCore
//
//  Created by Loki on 5/16/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import Swift

public extension Sequence where Element: NSAttributedString {
    func joinWith(separator: NSAttributedString) -> NSAttributedString {
        var isFirst = true
        return self.reduce(NSMutableAttributedString()) {
            (r, e) in
            if isFirst {
                isFirst = false
            } else {
                r.append(separator)
            }
            r.append(e)
            return r
        }
    }
    
    func joinWith(separator: String) -> NSAttributedString {
        return joinWith(separator: NSAttributedString(string: separator))
    }
}
