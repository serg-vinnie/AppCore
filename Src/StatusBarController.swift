//
//  StatusBarController.swift
//  SwiftCore
//
//  Created by Loki on 1/5/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation

public class StatusBarController : NSObject {
    private let icon         = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var popover      :  NSPopover?
    //private var eventMonitor : EventMonitor?
    
    public var isVisible : Bool { set { icon.isVisible = newValue } get { return icon.isVisible } }
    
    public override init() {
        super.init()
        
//        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
//            self?.showPopOver(false)
//        }

        icon.action = #selector(onClick)
        icon.button?.target = self
        icon.image = AppCore.bundle.image(forResource: "statusBarDebug")
    }
    
    public func set(img: NSImage) {
        icon.image = img
    }
    
    public func setPopOver(controller: NSViewController) {
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
            //eventMonitor?.start()
        } else {
            pop.performClose(self)
            //eventMonitor?.stop()
        }
    }
}
