//
//  SettingsBase.swift
//  SwiftCore
//
//  Created by Loki on 1/4/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import AsyncNinja

public class SettingsContext : ExecutionContext, ReleasePoolOwner {
    public let store : ConfigBackend
    public var executor: Executor { return Executor.main }
    public let releasePool = ReleasePool()
    
    public init(store: ConfigBackend) {
        self.store = store
    }
}
