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
        let container: Container
        
        required public init(container: Container) {
            self.container = container
        }
    }
    
    open class Global : ExecutionContext, ReleasePoolOwner {
        public var executor: Executor { return Executor.init(queue: DispatchQueue.global()) }
        public let releasePool = ReleasePool()
        let container: Container
        
        required public init(container: Container) {
            self.container = container
        }
    }
}

public class DaemonsService {
    var daemons = [Any]()
    
    public init(container: Container) {
        let allClasses = AllClasses()
        
        for item in allClasses.subclasses(of: Daemon.Main.self) {
            AppCore.log(title: "DaemonsService", msg: "adding item \(item)")
            let inst = item.init(container: container)
            daemons.append(inst)
        }
        
        for item in allClasses.subclasses(of: Daemon.Global.self) {
            AppCore.log(title: "DaemonsService", msg: "adding item \(item)")
            let inst = item.init(container: container)
            daemons.append(inst)
        }
    }
}
