//
//  ModifierFlags+Ninja.swift
//  AppCore
//
//  Created by Loki on 5/27/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja

public extension NSEvent.ModifierFlags {
    static func localAndGlobalMonitor() -> Channel<NSEvent.ModifierFlags,Void> {
        return merge(localMonitor(), globalMonitor())
            .mapCompletion() { _ in () }
    }
    
    static func localMonitor() -> Channel<NSEvent.ModifierFlags,Void> {
        return producer() { producer in
            let monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak producer] in
                producer?.update($0.modifierFlags)
                return $0
            }
            
            producer._asyncNinja_notifyFinalization() {
                AppCore.log(title: "NSEvent.ModifierFlag", msg: "localMonitor Finalization")
                NSEvent.removeMonitor(monitor!)
            }
        }
    }
    
    static func globalMonitor() -> Channel<NSEvent.ModifierFlags,Void> {
        return producer() { producer in
            let monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak producer] in
                producer?.update($0.modifierFlags)
                return $0
            }
            
            producer._asyncNinja_notifyFinalization() {
                AppCore.log(title: "NSEvent.ModifierFlag", msg: "globalMonitor Finalization")
                NSEvent.removeMonitor(monitor!)
            }
        }
    }
}

//public class ModifierFlagsR {
//    public let changed = BehaviorRelay<NSEvent.ModifierFlags>(value: NSEvent.ModifierFlags())
//
//
//    private lazy var monitorLocal : Any? = {
//        return NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] in
//            self?.changed.accept($0.modifierFlags)
//            return $0
//        }
//    }()
//
//    private lazy var monitorGlobal : Any? = {
//        return NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] in
//            self?.changed.accept($0.modifierFlags)
//        }
//    }()
//
//    public init() {
//        _ = monitorLocal
//        _ = monitorGlobal
//    }
//
//    deinit {
//        if let local = monitorLocal {
//            NSEvent.removeMonitor(local)
//        }
//        if let global = monitorGlobal {
//            NSEvent.removeMonitor(global)
//        }
//    }
//}
