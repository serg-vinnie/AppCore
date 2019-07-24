//
//  Random.swift
//  KeyKey
//
//  Created by Loki on 2/24/17.
//  Copyright © 2017 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public class Random {
        
    public static func entriesInSet(source : Set<Int>, count : Int) -> Set<Int> {
        var entries = Set<Int>()

        if (count < source.count) {
            while (entries.count < count) {
                let newValue = source.randomElement()!
                if !entries.contains(newValue) {
                    entries.insert(newValue)
                }
                
            }
        } else {
            for element in source {
                entries.insert(element)
            }
        }
        return entries;
    }
    
    
    public static func entriesInRange(_ from : Int, _ to : Int, count : Int) -> Set<Int> {
        var entries = Set<Int>()
        
        // check boundaries
        let maxRange = to  - from
        
        if (count < maxRange) {
            while (entries.count < count) {
                let newValue = Int.random(in: from ... to) //range(from, to)
                
                if !entries.contains(newValue) {
                    entries.insert(newValue)
                }
            }
        } else {
            for i in 0 ..< maxRange {
                entries.insert(from + i)
            }
        }
        return entries;
    }
    
    public static func rndIdxFrom(probabilities : [Int]) -> Int? {
        let sum = UInt32(probabilities.sum { $0 })
        var intervals = [(Int,Int)]()
        
        var intervalBegin = 1
        var intervalEnd = 0
        
        for item in probabilities {
            if item > 0 {
                intervalEnd += item
                intervals.append((intervalBegin,intervalEnd))
                intervalBegin = intervalEnd + 1
            } else {
                intervals.append( (0,0) )
            }
        }
        let rnd = Int(arc4random_uniform(sum)) + 1
        
        for i in 0 ..< intervals.count {
            let item = intervals[i]
            if rnd >= item.0 && rnd <= item.1 {
                return i + 1
            }
        }
        return nil
    }
    
    static func test() { // TODO: Move to unit test
        let probabilities = [1, 0, 1, 0, 1, 1, 1, 1, 1, 1]
        var testDic = [Int:Int]()
        
        for _ in 0...1000 {
            let v = Random.rndIdxFrom(probabilities: probabilities) ?? 4
            
            if testDic[v] != nil {
                testDic[v]! += 1
            } else {
                testDic[v] = 1
            }
        }
        
        for i in 1 ... probabilities.count {
            if testDic[i] != nil {
                print("\(i) : \(testDic[i]!)")
            } else {
                print("\(i) : 0")
            }
        }
    }
    
    public static var bool : Bool {
        return arc4random_uniform(10) < 5
    }
    
    public static func double(fractions: UInt32, from: Double, to: Double) -> Double {
        guard from < to else {
            fatalError()
        }
        
        let rnd = arc4random_uniform(fractions)
        let diff = to - from
        
        return diff / Double(fractions) * Double(rnd)
    }
}

public extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let distance: Int = Int(arc4random_uniform(UInt32(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: distance)
            swapAt(firstUnshuffled, i)
        }
    }
}

public extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
