//
//  ColorExtension.swift
//  AppCore
//
//  Created by UKS_neo on 29.12.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
public extension Color {
    init(hex: UInt32) {
        self.init(
            red:      Double((hex >> 16) & 0xFF) / 256.0,
            green:      Double((hex >> 8) & 0xFF) / 256.0,
            blue:      Double(hex & 0xFF) / 256.0
        )
    }
    
    init(rgbaHex: UInt32) {
        self.init(
            red:      Double((rgbaHex >> 24) & 0xFF) / 256.0,
            green:    Double((rgbaHex >> 16) & 0xFF) / 256.0,
            blue:     Double((rgbaHex >> 8) & 0xFF) / 256.0,
            opacity:  Double(rgbaHex & 0xFF) / 256.0
        )
    }
}
