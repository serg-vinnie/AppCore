//
//  NSView+TrackingArea+Ninja.swift
//  AppCore
//
//  Created by Loki on 5/25/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja

public extension ReactiveProperties where Object: NSView {
    func trackingAreaWith(options: NSTrackingArea.Options) -> Channel<NSEvent, Void> {
        return producer() { producer in
            
            let receiver = TrackingMessageReceiver(producer: producer)
            
            let area = NSTrackingArea.init(rect: self.object.bounds, options: options, owner: /* weak */ receiver, userInfo: nil)
            self.object.addTrackingArea(area)
            
            producer._asyncNinja_retainUntilFinalization(receiver)
            producer._asyncNinja_notifyFinalization {
                self.object.removeTrackingArea(area)
            }
        }
    }
    
    var trackingArea : Channel<NSEvent, Void> {
        return trackingAreaWith(options: [ .mouseEnteredAndExited, .activeAlways ])
    }
}

fileprivate class TrackingMessageReceiver : NSResponder {
    
    var producer: Producer<NSEvent, Void>
    
    init(producer: Producer<NSEvent, Void>) {
        self.producer = producer
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        producer.update(theEvent)
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        producer.update(theEvent)
    }
}
