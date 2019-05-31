//
//  StatusBarController.swift
//  SwiftCore
//
//  Created by Loki on 1/5/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import AsyncNinja

public extension Signal {
    struct StatusBar {
        public struct Click { public init() {} }
        public struct Visible {
            public let isVisible : Bool
            public init(_ value: Bool) {
                self.isVisible = value
            }
        }
    }
}

class StatusBarController : NSObject {
    private let icon         = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var popover      :  NSPopover?
    private var monitorToken = CancellationToken()
    
    override init() {
        super.init()

        icon.action = #selector(onClick)
        icon.button?.target = self
        icon.image = AppCore.bundle.image(forResource: "statusBarDebug")
        
        AppCore.signals.subscribeFor(Signal.StatusBar.Visible.self)
            .onUpdate() { [weak self] signal in self?.icon.isVisible = signal.isVisible }
    }
    
    func set(img: NSImage) {
        icon.image = img
    }
    
    func setPopOver(controller: NSViewController) {
        if popover == nil {
            popover = NSPopover()
            popover!.behavior = NSPopover.Behavior.transient
        }
        popover?.contentViewController = controller
    }
}

private extension StatusBarController {
    @objc func onClick() {
        switchPopOver()
        AppCore.signals.send(signal: Signal.StatusBar.Click())
    }

    func switchPopOver() {
        guard let pop = popover else { return }
        
        showPopOver(!pop.isShown)
    }
    
    func showPopOver(_ show: Bool) {
        guard
            let btn = icon.button,
            let pop = popover else { return }
        
        if show {
            pop.show(relativeTo: btn.bounds, of: btn, preferredEdge: NSRectEdge.minY)
            startMonitor()
        } else {
            pop.performClose(self)
            stopMonitor()
        }
    }
    
    func startMonitor() {
        NSEvent.globalMonitor(matching: [.leftMouseDown, .rightMouseDown], cancellationToken: monitorToken)
            .onUpdate(context: popover!) { [weak self] _, _ in self?.showPopOver(false) }
    }
    
    func stopMonitor() {
        monitorToken.cancel()
    }
}
