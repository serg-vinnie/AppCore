//
//  DaemonsService.swift
//  AppCore
//
//  Created by Loki on 6/1/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja


public class Daemon {
    open class Main : ExecutionContext, ReleasePoolOwner {
        public var executor: Executor { return Executor.init(queue: DispatchQueue.main) }
        public let releasePool = ReleasePool()
        let signals : SignalsService
        
        required public init(signals : SignalsService) {
            self.signals = signals
        }
    }
}

public class DaemonsService {
    let signals : SignalsService
    var daemons = [Any]()
    
    public init(signals: SignalsService) {
        self.signals = signals
        
        for item in subclasses(of: Daemon.Main.self) {
            AppCore.log(title: "DaemonsService", msg: "\(item)")
            let inst = item.init(signals: signals)
            daemons.append(inst)
        }
    }
}
