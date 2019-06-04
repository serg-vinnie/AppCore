//
//  ContainerViewController.swift
//  CoherentMac
//
//  Created by Loki on 6/28/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation

open class ContainerViewController : NSViewController {
    
    private(set) var content               : NSViewController?
    public       var transitionOptions     : NSViewController.TransitionOptions = [.crossfade, .allowUserInteraction]
    public       var immediateTransition   = false
    private(set) var inTransition          = false //BehaviorRelay<Bool>(value: false)
    
    public var nextController   : NSViewController? { didSet { transitionTo(controller: nextController) } }
    
    public func display(controller: NSViewController) {
        remove(content: content)
        
        addChild(controller)
        controller.view.frame = view.frame
        self.view.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.fitTo(view: view)
        
        content = controller
    }
    
    public func transitionTo(controller: NSViewController?) {
        guard let controller = controller else {
            if let content = content { remove(content: content) }
            return
        }
        
        guard let content = content else {      //don't do transition if empty – just dispay
            display(controller: controller);
            return
        }
        
        guard content != controller else {      //don't do transition to itself
            return
        }
        
        if immediateTransition {
            display(controller: controller);
            return
        }
        
        addChild(controller)
        inTransition = true
        
        transition(from: content, to: controller, options: transitionOptions) { [weak self] in
            self?.remove(content: content)
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            if let view = self?.view {
                controller.view.fitTo(view: view)
            }
            
            self?.content = controller
            self?.inTransition = false
        }
    }
    
    public func remove(content: NSViewController?) {
        content?.view.translatesAutoresizingMaskIntoConstraints = true
        content?.view.removeFromSuperview()
        content?.removeFromParent()
    }
}
