//
//  NSViewController+Ext.swift
//  CoherentMac
//
//  Created by Loki on 6/28/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import AppKit

public extension NSViewController {
    func childBy<T>(type: T.Type) -> T {
        return children.first(where: { $0 is T })  as! T
    }
}

