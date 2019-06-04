//
//  NinjaViewModel.swift
//  AppCore
//
//  Created by Loki on 1/29/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import AsyncNinja

public class NinjaContext {
    open class Main : ExecutionContext, ReleasePoolOwner {
        public var executor: Executor { return Executor.init(queue: DispatchQueue.main) }
        public let releasePool = ReleasePool()
        
        public init() {
            
        }
    }
    
    open class Global : ExecutionContext, ReleasePoolOwner {
        public var executor: Executor { return Executor.init(queue: DispatchQueue.global()) }
        public let releasePool = ReleasePool()
        
        public init() {
            
        }
    }
}
