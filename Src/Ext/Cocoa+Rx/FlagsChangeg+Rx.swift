//
//  FlagsChangeg+Rx.swift
//  CoherentMac
//
//  Created by Loki on 6/19/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
import Cocoa
import RxCocoa

public class ModifierFlagsRx {
    public let changed = BehaviorRelay<NSEvent.ModifierFlags>(value: NSEvent.ModifierFlags())
    
    
    private lazy var monitorLocal : Any? = {
        return NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] in
            self?.changed.accept($0.modifierFlags)
            return $0
        }
    }()
    
    private lazy var monitorGlobal : Any? = {
        return NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] in
            self?.changed.accept($0.modifierFlags)
        }
    }()
    
    public init() {
        _ = monitorLocal
        _ = monitorGlobal
    }
    
    deinit {
        if let local = monitorLocal {
            NSEvent.removeMonitor(local)
        }
        if let global = monitorGlobal {
            NSEvent.removeMonitor(global)
        }
    }
}
