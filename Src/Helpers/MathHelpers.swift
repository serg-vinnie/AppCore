//
//  MathHelpers.swift
//  KeyKey
//
//  Created by Loki on 2/11/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public func clamp<T: Comparable>(_ val: T, min: T, max: T) -> T {
    
    if val < min { return min }
    if val > max { return max }
    return val
}

public func lerp<T: FloatingPoint>(_ val: T, min: T, max: T) -> T {
    return min + val * (max - min)
}

public extension Double {
    func lerp(min: Double, max: Double) -> Double {
        return min + self * (max - min)
    }
}
