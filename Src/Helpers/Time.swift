//
//  File.swift
//  Coherent
//
//  Created by Loki on 5/24/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation

public class Time {
    public var gregorian = Calendar(identifier: .iso8601)
    
    public init() {}
    
    public func dayOf(date: Date) -> Date { return gregorian.date(from: gregorian.dateComponents([.year, .month, .day],             from: date))! }
    
    public func today() -> Date      { return gregorian.date(from: gregorian.dateComponents([.year, .month, .day],             from: Date()))! }
    public func thisMonday() -> Date { return gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))! }
    public func thisMonth() -> Date  { return gregorian.date(from: gregorian.dateComponents([.year, .month],                   from: Date()))! }
    public func thisYear() -> Date   { return gregorian.date(from: gregorian.dateComponents([.year],                           from: Date()))! }
    
    public func days(from: Date, to: Date) -> Int? { return gregorian.dateComponents([.day], from: from, to: to).day }
}

public extension Time {
    static func secondsFrom(timeInterval: TimeInterval) -> Int {
        return Int(timeInterval) % 60
    }
    
    static func minutesFrom(timeInterval: TimeInterval) -> Int {
        return Int(timeInterval) / 60
    }
}

public extension Date {
    func plus(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

public extension Time {
    
    func plusDay(_ date : Date, offset: Int = 1) -> Date {
        var plus = DateComponents(); plus.day = offset
        return gregorian.date(byAdding: plus, to: date)!
    }
    
    func plusWeek(_ date: Date, offset: Int = 1) -> Date {
        var plus = DateComponents(); plus.weekOfYear = offset
        return gregorian.date(byAdding: plus, to: date)!
    }
    
    func plusMonth(_ date : Date, offset: Int = 1) -> Date {
        var plus = DateComponents(); plus.month = offset
        return gregorian.date(byAdding: plus, to: date)!
    }
    
    func plusYear(_ date : Date, offset: Int = 1) -> Date {
        var plus = DateComponents(); plus.year = offset
        return gregorian.date(byAdding: plus, to: date)!
    }
}

public extension Time {
    func daysFromToday(count: Int)-> [(Date,Date)] {
        let start = today()
        var result = [Date]()
        
        for i in 0 ..< count {
            result.append( plusDay(start, offset: -i) )
        }
        return result.map { ($0, plusDay($0)) }
    }
    
    func weeksFromNow(count: Int) -> [(Date,Date)] {
        let _thisMonday = thisMonday()
        var result = [Date]()
        
        for i in 0 ..< count {
            result.append( plusWeek(_thisMonday, offset: -i) )
        }
        return result.map { ($0, plusWeek($0)) }
    }
    
    func monthsFromNow(count: Int) -> [(Date,Date)] {
        let _thisMonth = thisMonth()
        var result = [Date]()
        
        for i in 0 ..< count {
            result.append( plusMonth(_thisMonth, offset: -i) )
        }
        return result.map { ($0, plusMonth($0)) }
    }
    
    func yearsFromNow(count: Int) -> [(Date,Date)] {
        let _thisYear = thisYear()
        var result = [Date]()
        
        for i in 0 ..< count {
            result.append( plusYear(_thisYear, offset: -i) )
        }
        return result.map { ($0, plusYear($0)) }
    }
}

public extension Time {
    func daysBetwen( _ from: Date, and to: Date) -> [Date] {
        var date = dayOf(date: from)
        let endDate = dayOf(date: to)
        var result = [Date]()
        
        while date <= endDate {
            result.append(date)
            date = gregorian.date(byAdding: .day, value: 1, to: date)!
        }
        
        return result
    }
}
