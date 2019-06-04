
//
//  File.swift
//  CoherentMac
//
//  Created by Loki on 7/3/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Cocoa

public extension NSStackView {
    func detachAllArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
