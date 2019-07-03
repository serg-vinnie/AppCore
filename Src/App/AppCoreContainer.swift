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
import CloudKit

fileprivate let publicDB  = CKContainer.default().publicCloudDatabase
fileprivate let privateDB = CKContainer.default().privateCloudDatabase
fileprivate let cloudQueueID = "iCloudThread"

func AppCoreContainer(env : ServiceEnvironment) -> Container {
    return Container(defaultObjectScope: .container) { c in
        c.register(ServiceEnvironment.self) { _ in return env }
        
        c.register(ConfigBackend.self) { r in r.resolve(ConfigUserDefaults.self)! }
        c.autoregister(ConfigUserDefaults.self, initializer: ConfigUserDefaults.init)
        
        c.register(iCloudRxService.self, name: "public") { _ in
            iCloudRxService(container: CKContainer.default(), cloudDB:publicDB, queueId: cloudQueueID)
        }
        //c.register(iCloudRxService.self) { r in r.resolve(iCloudRxService.self, name: "public")! }
        
        c.register(iCloudRxService.self, name: "private") { _ in
            iCloudRxService(container: CKContainer.default(), cloudDB: privateDB, queueId: cloudQueueID)
        }
        
        c.autoregister(iCloundNinjaPrivate.self,    initializer: iCloundNinjaPrivate.init)
        c.autoregister(iCloundNinjaPublic.self,     initializer: iCloundNinjaPublic.init)
        
        
        c.register(SignalsService.self)     { _ in return SignalsService.main }
        c.autoregister(StatesService.self,       initializer: StatesService.init)
        c.autoregister(Scenes.self,              initializer: Scenes.init)        
    }
}
    
public extension Container {
    func `do`(_ block: (Container) throws -> Void) rethrows {
        try block(self)
    }
}

public func fileName(alias: String, env: ServiceEnvironment) -> String {
    switch env {
    case .Release: return alias
    case .Debug:   return "\(alias)_dbg.realm"
    case .Test:    return "\(alias)_tst.realm"
    }
}

