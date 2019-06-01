//
//  ClassInfo.swift
//  AppCore
//
//  Created by Loki on 6/1/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation

public func subclasses<T>(of theClass: T) -> [T] {
    var count: UInt32 = 0, result: [T] = []
    let allClasses = objc_copyClassList(&count)!
    let classPtr = address(of: theClass)
    
    for n in 0 ..< count {
        let someClass: AnyClass = allClasses[Int(n)]
        guard let someSuperClass = class_getSuperclass(someClass), address(of: someSuperClass) == classPtr else { continue }
        result.append(someClass as! T)
    }
    
    return result
}

private func address(of object: Any?) -> UnsafeMutableRawPointer{
    return Unmanaged.passUnretained(object as AnyObject).toOpaque()
}
