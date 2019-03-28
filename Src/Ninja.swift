//
//  NinjaViewModel.swift
//  AppCore
//
//  Created by Loki on 1/29/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import AsyncNinja

open class Ninja : ExecutionContext, ReleasePoolOwner {
    public let dispatchQueue = DispatchQueue.main
    public var executor: Executor { return Executor.init(queue: dispatchQueue) }
    public let releasePool = ReleasePool()

    public init() {
        
    }
}

open class NinjaBackground : ExecutionContext, ReleasePoolOwner {
    public let dispatchQueue = DispatchQueue.global()
    public var executor: Executor { return Executor.init(queue: dispatchQueue) }
    public let releasePool = ReleasePool()
    
    public init() {
        
    }
}
