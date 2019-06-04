//
//  DictionaryExt.swift
//  KeyKey
//
//  Created by Loki on 4/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public extension Dictionary {
    mutating func verifyExistanceOf(key: Key, defaultValue: Value) -> Value {
        if let val = self[key] {
            return val
        } else {
            self[key] = defaultValue
            return defaultValue
        }
    }
}

public extension Dictionary where Value == Int {
    mutating func incrementIntFor(key: Key) {
        if self[key] == nil {
            self[key] = 0
        }
        
        self[key]! += 1
    }
}
