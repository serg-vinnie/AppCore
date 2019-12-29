//
//  ifModifier.swift
//  AppCore
//
//  Created by UKS_neo on 29.12.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import SwiftUI

@available(OSX 10.15, *)
public extension View {
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }
}
