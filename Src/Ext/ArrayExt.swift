//
//  CollectionExt.swift
//  KeyKey
//
//  Created by Loki on 3/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public extension Array {
    func mapTo<Element2,JointType>(_ arr: Array<Element2>, mapper: (Element?,Element2?)->(JointType)) -> [JointType]
    {
        var result = [JointType]()
        
        let maxIdx = Swift.max(count, arr.count) - 1
        if maxIdx > 0 {
            for i in 0 ... maxIdx {
                var item1 : Element?
                var item2 : Element2?
                
                if self.count > i {
                    item1 = self[i]
                }
                
                if arr.count > i {
                    item2 = arr[i]
                }
                
                result.append(mapper(item1, item2))
            }
        }
        return result
    }
    
    func sum<T: Numeric>(_ getter: (Element)->(T)) -> T {
        return self.map(getter).reduce(0, +)
    }
    
    func join(_ getter: (Element)->(String)) -> String {
        return self.map(getter).reduce("", +)
    }
    
    func splitBy(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
    
    mutating func removeFirst(where predicate: (Element)->(Bool)) {
        if let idx = self.firstIndex(where: predicate) {
            remove(at: idx)
        }
    }
    
    func recursiveFlatMap(_ getter: (Element)->([Element])) -> [Element] {
        var results = [Element]()
        results.append(contentsOf: self)
        
        for item in self {
            results.append(contentsOf: getter(item).recursiveFlatMap(getter) )
        }
        
        return results
    }
}
