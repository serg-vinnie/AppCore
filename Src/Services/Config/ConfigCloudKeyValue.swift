//
//  ConfigBackendCloudKit.swift
//  Coherent
//
//  Created by Loki on 6/2/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation

public class ConfigCloudKeyValue : ConfigBackend {
    
    let store = NSUbiquitousKeyValueStore.default
        
    public func clear() {
        for (key, _) in store.dictionaryRepresentation {
            store.removeObject(forKey: key)
        }
        store.synchronize()
    }

    
    public func set(value: Any?, key: String) {
        guard let value = value else {
            store.removeObject(forKey: key)
            return
        }
        
        switch value {
            
        case let val as Int64:  store.set(val, forKey: key)
        case let val as String: store.set(val, forKey: key)
        case let val as Double: store.set(val, forKey: key)
        case let val as Bool:   store.set(val, forKey: key)
            
        default: fatalError()
        }
        
    }
    
    public func value<T>(key: String, ofType: T.Type) -> Any? where T : Equatable {
        switch ofType {
            
        case is Int64.Type:     return store.longLong(forKey: key)
        case is Double.Type:    return store.double(forKey: key)
        case is Bool.Type:      return store.bool(forKey: key)
        case is String.Type:    return store.string(forKey: key)
        default: fatalError()
        }
    }
}
