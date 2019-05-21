//
//  ContainerViewController.swift
//  CoherentMac
//
//  Created by Loki on 6/28/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation

import Cocoa
import RxSwift
import RxCocoa

open class ContainerViewController : NSViewController {
    public let bag          = DisposeBag()
    
    private(set) var content               : NSViewController?
    public       var transitionOptions     : NSViewController.TransitionOptions = [.crossfade, .allowUserInteraction]
    public       var immediateTransition   = false
    private(set) var inTransition          = BehaviorRelay<Bool>(value: false)
    
    public lazy var nextController   : BehaviorRelay<NSViewController?> =  {
        let behavior = BehaviorRelay<NSViewController?>(value: nil)
        
        behavior
            //.throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] next in
                guard let next = next else { return }
                self?.transitionTo(controller: next)
            }).disposed(by: bag)
        
        return behavior
    }()
    
    public func display(controller: NSViewController) {
        remove(content: content)
        
        addChild(controller)
        controller.view.frame = view.frame
        self.view.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.fitTo(view: view)
        
        content = controller
    }
    
    public func transitionTo(controller: NSViewController) {
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
        inTransition.accept(true)
        
        transition(from: content, to: controller, options: transitionOptions) {
            self.remove(content: content)
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.fitTo(view: self.view)
            
            self.content = controller
            self.inTransition.accept(false)
        }
    }
    
    public func remove(content: NSViewController?) {
        content?.view.translatesAutoresizingMaskIntoConstraints = true
        content?.view.removeFromSuperview()
        content?.removeFromParent()
    }
}
