//
//  Xib.swift
//  CoherentMac
//
//  Created by Loki on 6/22/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Cocoa

public extension NSObject {
    func loadViewFromXib(id: String) -> NSView? {
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(NSNib.Name(id), owner: self, topLevelObjects: &topLevelObjects) {
            return topLevelObjects?.first(where: { $0 is NSView } ) as? NSView
        }
        print("can't load \(id)")
        return nil
    }
    
    func loadAllFromXib(id: String) -> NSArray? {
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(NSNib.Name(id), owner: self, topLevelObjects: &topLevelObjects) {
            return topLevelObjects
        }
        print("can't load \(id)")
        return nil
    }
}
