//
//  NSView+TrackingArea+Rx.swift
//  CoherentMac
//
//  Created by Loki on 6/28/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import AppKit
import RxSwift
import RxCocoa

#if os(macOS)

public enum TrackingAreaEventRx {
    case mouseEntered
    case mouseOut
}

fileprivate class TrackingMessageReceiver : NSResponder {
    
    var observer: AnyObserver<TrackingAreaEventRx>
    
    init(observer: AnyObserver<TrackingAreaEventRx>) {
        self.observer = observer
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        //observable.
        observer.onNext(.mouseEntered)
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        observer.onNext(.mouseOut)
    }
}

public extension Reactive where Base: NSView {
    
    func trackingAreaWith(options: NSTrackingArea.Options) -> ControlEvent<TrackingAreaEventRx> {
        let src = Observable<TrackingAreaEventRx>.create { observer in
            
            let receiver = TrackingMessageReceiver(observer: observer)
            let userInfo = ["receiver": receiver] // owner reference is weak, so we need additional strong reference
            
            let area = NSTrackingArea.init(rect: self.base.bounds, options: options, owner: /* weak */ receiver, userInfo: userInfo)
            self.base.addTrackingArea(area)
            
            return Disposables.create {
                self.base.removeTrackingArea(area)
            }
        }
        
        return ControlEvent(events: src)
    }
    
    var trackingArea : ControlEvent<TrackingAreaEventRx> {
        return trackingAreaWith(options: [ .mouseEnteredAndExited, .activeAlways ])
    }
}

#endif
