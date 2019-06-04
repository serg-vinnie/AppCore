//
//  TimerZbs.swift
//  CoherentMac
//
//  Created by Loki on 6/20/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
import RxSwift

public class TimerZbs {
    static var timers = [String:Disposable]()

    public class func start(id: String, interval: TimeInterval, code: @escaping ()->()) {
        stop(id: id)
        timers[id] = Observable<Int>.interval(interval, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in code() })
    }
    
    public class func stop(id: String) {
        if let timer = timers[id] {
            timer.dispose()
            timers[id] = nil
        }
    }
}
