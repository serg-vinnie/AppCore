//
//  Container.swift
//  AppCore
//
//  Created by Loki on 10/4/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration


func AppCoreContainer(env : ServiceEnvironment) -> Container {
    return Container(defaultObjectScope: .container) { c in
        c.register(ServiceEnvironment.self) { _ in return env }
        
        c.autoregister(SignalsService.self,      initializer: SignalsService.init)
        c.autoregister(StatesService.self,       initializer: StatesService.init)
        c.autoregister(Scenes.self,              initializer: Scenes.init)        
    }
}
    
public extension Container {
    public func `do`(_ block: (Container) throws -> Void) rethrows {
        try block(self)
    }
}

