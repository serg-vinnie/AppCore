//
//  ConfigR.swift
//  SwiftCore
//
//  Created by Loki on 1/4/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import AsyncNinja
import RxSwift
import RxCocoa


public class ConfigR<T : Equatable>  {
    public let store           : ConfigBackend
    public let key             : String
    public let defaultValue    : T
    
    public var didSet           : Channel<T, Void>      { return valueR }
    public var didSetFromTo     : Channel<(T,T),Void>   { return valueFromTo }
    public var didChangeRx      : Observable<T>         { return valueRx.asObservable() }
    
    private let valueR          : DynamicProperty<T>
    private let valueFromTo     = Producer<(T,T),Void>()
    private let valueRx         : BehaviorRelay<T>
    
    public var value           : T {
        set { set(value: newValue) }
        get { return valueR.value }
    }
    
    public init(key: String, defaultValue: T, context: SettingsContext) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = context.store
        
        let value = store.value(key: key, ofType: T.self) as? T
        self.valueR = context.makeDynamicProperty(value ?? defaultValue)
        self.valueRx = BehaviorRelay<T>(value: value ?? defaultValue)
    }
    
    public func setDefault() {
        value = defaultValue
    }
    
    private func set(value: T) {
        AppCore.log(title: "ConfigR", msg: "\(key) - \(value)", thread: true)
        store.set(value: value, key: key)
        valueFromTo.update((valueR.value,value))
        valueR.value = value
        valueRx.accept(value)
    }
    
}

public class ConfigREnum<T: RawRepresentable> where T.RawValue : Equatable  {
    public let store           : ConfigBackend
    public let key             : String
    public let defaultValue    : T
    public let context         : ExecutionContext
    
    public var didChange        : Channel<T, Void>      { return valueR }
    public var didSetFromTo     : Channel<(T,T),Void>   { return valueFromTo }
    public var didChangeRx      : Observable<T>         { return valueRx.asObservable() }
    
    private let valueR          : DynamicProperty<T>
    private let valueFromTo     = Producer<(T,T),Void>()
    private let valueRx         : BehaviorRelay<T>

    public var value           : T {
        set { set(value: newValue) }
        get { return valueR.value }
    }

    public init(key: String, defaultValue: T, context: SettingsContext) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = context.store
        self.context = context

        if let storedValue = store.value(key: key, ofType: T.RawValue.self) as? T.RawValue {
            let value = T(rawValue: storedValue)
            self.valueR = context.makeDynamicProperty(value ?? defaultValue)
            self.valueRx = BehaviorRelay<T>(value: value ?? defaultValue)
        } else {
            self.valueR = context.makeDynamicProperty(defaultValue)
            self.valueRx = BehaviorRelay<T>(value: defaultValue)
        }
    }

    public func setDefault() {
        value = defaultValue
    }

    private func set(value: T) {
        store.set(value: value.rawValue, key: key)
        valueR.value = value
        valueRx.accept(value)
    }
}
