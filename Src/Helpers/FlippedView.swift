//
//  FlippedView.swift
//  TaoGit
//
//  Created by Loki on 5/19/19.
//  Copyright © 2019 Cheka Zuja. All rights reserved.
//

import Foundation
import AppKit

// hack for NSScrollView
public class FlippedView : NSView {
    override public var isFlipped: Bool { return true }
    
    override public func resize(withOldSuperviewSize oldSize: NSSize) {
        assert(superview != nil)
        guard let superViewHeight = self.superview?.frame.size.height else { return }
        let height = self.frame.size.height
        
        if superViewHeight > height {
           setFrameOrigin(NSMakePoint(frame.origin.x, superViewHeight - height))
        }
    }
}
