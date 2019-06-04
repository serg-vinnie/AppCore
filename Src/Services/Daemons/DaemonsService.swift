//
//  DaemonsService.swift
//  AppCore
//
//  Created by Loki on 6/1/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja
import Swinject


public class Daemon {
    open class Main : ExecutionContext, ReleasePoolOwner {
        public var executor: Executor { return Executor.init(queue: DispatchQueue.main) }
        public let releasePool = ReleasePool()
        let signals : SignalsService
        let container: Container
        
        required public init(signals : SignalsService, container: Container) {
            self.signals = signals
            self.container = container
        }
    }
    
    open class Global : ExecutionContext, ReleasePoolOwner {
        public var executor: Executor { return Executor.init(queue: DispatchQueue.global()) }
        public let releasePool = ReleasePool()
        let signals : SignalsService
        let container: Container
        
        required public init(signals: SignalsService, container: Container) {
            self.signals = signals
            self.container = container
        }
    }
}

public class DaemonsService {
    var daemons = [Any]()
    
    public init(signals: SignalsService, container: Container) {
        for item in subclasses(of: Daemon.Main.self) {
            AppCore.log(title: "DaemonsService", msg: "adding item \(item)")
            let inst = item.init(signals: signals, container: container)
            daemons.append(inst)
        }
    }
}
