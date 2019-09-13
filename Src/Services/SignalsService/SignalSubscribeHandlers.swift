//
//  SignalSubscribeHandlers.swift
//  AppCore
//
//  Created by Loki on 9/13/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation

func initSignalSubscribeHandlers() {
    initDateChange()
}

func initDateChange() {
    var lastDay = Time().dayOf(date: Date())
    
    SignalsService.main.onSubscribe(Signal.DateDidChange.self)
        .take(1, completion: ())
        .onUpdate {
            TimerZbs.start(id: "DateDidChange", interval: 1) {
                let today = Time().dayOf(date: Date())
                
                if lastDay != today {
                    SignalsService.main.send(signal: Signal.DateDidChange(from: lastDay, to: today))
                    lastDay = today
                }
            }
    }
}
