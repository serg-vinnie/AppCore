//
//  ConfigBackendProtocol.swift
//  Coherent
//
//  Created by Loki on 6/2/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation

public protocol ConfigBackend {
    func set(value: Any?,    key: String)
    func value<T: Equatable> (key: String, ofType: T.Type) -> Any?
    func clear()
}
