/*
 MIT License
 
 Copyright (c) 2014 Sergiy Vynnychenko
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import AsyncNinja
import RxSwift

public class StatesService {
    private var states = [AnyHashable:Any]()
    
    public func set<ValueType>(value: ValueType, forKey key: AnyHashable) {
        #if DEBUG
        if Mirror(reflecting: value).displayStyle == .class {
            fatalError("StateMonitorService accepts only structs as value. Can't accept class")
        }
        #endif
        
        if let item = getItem(key: key) as StatesServiceItem<ValueType>? {
            item.value = value
        } else {
            states[key] = StatesServiceItem(value)
        }
    }
    
    public func valueFor<ValueType>(key: AnyHashable) -> ValueType? {
        return getItem(key: key)?.value
    }
    
    public func subscribeFor<ValueType>(key: AnyHashable, valueOfType: ValueType.Type) -> Producer<ValueType,Void> {
        if let item = getItem(key: key) as StatesServiceItem<ValueType>? {
            return item.didChange
        } else {
            states[key] = StatesServiceItem<ValueType>()
            return getItem(key: key)!.didChange
        }
    }
    
    public func subscribeRxFor<ValueType>(key: AnyHashable, type: ValueType.Type) -> Observable<ValueType> {
        if let item = getItem(key: key) as StatesServiceItem<ValueType>? {
            return item.didChangeRx
        } else {
            states[key] = StatesServiceItem<ValueType>()
            return getItem(key: key)!.didChangeRx
        }
    }
}

public extension StatesService { // type as key
    func set<KeyType, ValueType>(value: ValueType, forKey key: KeyType.Type) {
        let hash = ObjectIdentifier(key).hashValue
        set(value: value, forKey: hash)
    }
    
    func valueFor<KeyType, ValueType>(key: KeyType.Type) -> ValueType? {
        let hash = ObjectIdentifier(key).hashValue
        return getItem(key: hash)?.value
    }
    
    func subscribeFor<KeyType, ValueType>(key: KeyType.Type, type: ValueType.Type) -> Producer<ValueType,Void> {
        let hash = ObjectIdentifier(key).hashValue
        return subscribeFor(key: hash, valueOfType: type)
    }
    
    func subscribeRxFor<KeyType, ValueType>(key: KeyType.Type, type: ValueType.Type) -> Observable<ValueType> {
        let hash = ObjectIdentifier(key).hashValue
        return subscribeRxFor(key: hash, type: type)
    }
}

private extension StatesService {
    func getItem<ValueType>(key: AnyHashable) -> StatesServiceItem<ValueType>? {
        if let dicItem = states[key] {
            guard let item = dicItem as? StatesServiceItem<ValueType> else {
                let msg = "ERROR - key \(key) is already bound to type \(type(of:dicItem)). Can't bind to \(ValueType.self)"
                AppCore.log(title: "StateMonitorService", msg: msg)
                assert(false)
                return nil
            }
            
            return item
        }
        
        return nil
    }
}
