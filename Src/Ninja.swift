//
//  NinjaViewModel.swift
//  SwiftCore
//
//  Created by Loki on 1/29/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import AsyncNinja

open class Ninja : ExecutionContext, ReleasePoolOwner {
    public var executor: Executor { return Executor.init(queue: DispatchQueue.main) }
    public let releasePool = ReleasePool()

    public init() {
        
    }
}

open class NinjaBackground : ExecutionContext, ReleasePoolOwner {
    public var executor: Executor { return Executor.background }
    public let releasePool = ReleasePool()
    
    public init() {
        
    }
}
