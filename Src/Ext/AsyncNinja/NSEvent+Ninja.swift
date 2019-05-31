//
//  ModifierFlags+Ninja.swift
//  AppCore
//
//  Created by Loki on 5/27/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja

public extension NSEvent {
    static func localAndGlobalMonitor(matching mask: NSEvent.EventTypeMask) -> Channel<NSEvent,Void> {
        return merge(localMonitor(matching: mask), globalMonitor(matching: mask))
            .mapCompletion() { _ in () }
    }
    
    static func localMonitor(matching mask: NSEvent.EventTypeMask) -> Channel<NSEvent,Void> {
        return producer() { producer in
            let monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak producer] in
                producer?.update($0)
                return $0
            }
            
            producer._asyncNinja_notifyFinalization() {
                AppCore.log(title: "NSEvent.ModifierFlag", msg: "localMonitor Finalization")
                NSEvent.removeMonitor(monitor!)
            }
        }
    }
    
    static func globalMonitor(matching mask: NSEvent.EventTypeMask, cancellationToken: CancellationToken? = nil) -> Channel<NSEvent,Void> {
        return producer(cancellationToken: cancellationToken) { producer in
            let monitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak producer] in
                producer?.update($0)
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
