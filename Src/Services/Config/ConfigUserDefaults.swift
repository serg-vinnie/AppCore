//
//  File.swift
//  Coherent
//
//  Created by Loki on 6/23/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation

public class ConfigUserDefaults : ConfigBackend {
    let store : UserDefaults
    let name  : String
    
    public init(env: ServiceEnvironment) {
        self.name = env.rawValue
        print("ConfigUserDefaults: \(name)")
        
        self.store = UserDefaults(suiteName: name)!
    }
    
    public func clear() {
        store.removePersistentDomain(forName: name)
    }
    
    public func set(value: Any?, key: String) {
        guard let value = value else {
            store.removeObject(forKey: key)
            return
        }
        
        switch value {
        case let val as Int:      store.set(NSNumber(value: Int64(val) ), forKey: key)
        case let val as Int32:    store.set(NSNumber(value: Int64(val) ), forKey: key)
        case let val as Int64:    store.set(NSNumber(value: val),         forKey: key)
        default:            store.set(value, forKey: key)
        }
    }
    
    public func value<T>(key: String, ofType: T.Type) -> Any? where T : Equatable {
        switch ofType {
            
        case is Int64.Type:     return (store.object(forKey: key) as? NSNumber)?.int64Value
        case is Int.Type:       return (store.object(forKey: key) as? NSNumber)?.intValue
        case is Int32.Type:     return (store.object(forKey: key) as? NSNumber)?.int32Value
        case is Double.Type:    return store.double(forKey: key)
        case is Bool.Type:      return store.bool(forKey: key)
        case is String.Type:    return store.string(forKey: key)
        default: fatalError()
        }

    }
}

