//
//  ConfigRx.swift
//  Coherent
//
//  Created by Loki on 6/2/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ConfigRx<T : Equatable>  {
    public let store           : ConfigBackend
    public let key             : String
    public let defaultValue    : T
    
    public var didChange      : Observable<T> { return valueRx.asObservable() }
    
    private let valueRx : BehaviorRelay<T>
    
    public var value           : T {
        set { set(value: newValue) }
        get { return valueRx.value }
    }
    
    public init(key: String, defaultValue: T, store: ConfigBackend) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
        
        let value = store.value(key: key, ofType: T.self) as? T
        self.valueRx = BehaviorRelay<T>(value: value ?? defaultValue)
    }
    
    public func setDefault() {
        value = defaultValue
    }
    
    private func set(value: T) {
        store.set(value: value, key: key)
        valueRx.accept(value)
    }

}

public class ConfigRxEnum<T: RawRepresentable> where T.RawValue : Equatable  {
    public let store           : ConfigBackend
    public let key             : String
    public let defaultValue    : T
    
    public var didChange      : Observable<T> { return valueRx.asObservable() }
    
    private let valueRx : BehaviorRelay<T>
    
    public var value           : T {
        set { set(value: newValue) }
        get { return valueRx.value }
    }
    
    public init(key: String, defaultValue: T, store: ConfigBackend) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
        
        if let storedValue = store.value(key: key, ofType: T.RawValue.self) as? T.RawValue {
            let value = T(rawValue: storedValue)
            self.valueRx = BehaviorRelay<T>(value: value ?? defaultValue)
        } else {
            self.valueRx = BehaviorRelay<T>(value: defaultValue)
        }
    }
    
    public func setDefault() {
        value = defaultValue
    }
    
    private func set(value: T) {
        store.set(value: value.rawValue, key: key)
        valueRx.accept(value)
    }
}
