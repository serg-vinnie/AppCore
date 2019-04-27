//
//  NSProgressIndicator+Rx.swift
//  FocusitoMac
//
//  Created by Loki on 8/8/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

#if os(macOS)
public extension Reactive where Base: NSProgressIndicator {
    
    var isAnimated: Binder<Bool> {
        return Binder(self.base) { (owner, value) in
            if value {
                owner.startAnimation(nil)
            } else {
                owner.stopAnimation(nil)
            }
        }
    }
    
    var isAnimatedAndVisible: Binder<Bool> {
        return Binder(self.base) { (owner, value) in
            if value {
                owner.isHidden = false
                owner.startAnimation(nil)
            } else {
                owner.isHidden = true
                owner.stopAnimation(nil)
            }
        }
    }
}
#endif
