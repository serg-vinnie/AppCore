//
//  AcceptFirstMouseModifier.swift
//  AppCore
//
//  Created by UKS_neo on 05.01.2020.
//  Copyright © 2020 Loki. All rights reserved.
//

import SwiftUI
import Cocoa

@available(OSX 10.15, *)
// Just mouse accepter
class MyViewView : NSView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

@available(OSX 10.15, *)
// Representable wrapper (bridge to SwiftUI)
struct AcceptingFirstMouse : NSViewRepresentable {

    func makeNSView(context: NSViewRepresentableContext<AcceptingFirstMouse>) -> MyViewView {
        return MyViewView()
    }

    func updateNSView(_ nsView: MyViewView, context: NSViewRepresentableContext<AcceptingFirstMouse>) {
        nsView.setNeedsDisplay(nsView.bounds)
    }

    typealias NSViewType = MyViewView
}

@available(OSX 10.15, *)
struct AcceptMouseClick: ViewModifier {
    public var actions: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(AcceptingFirstMouse())
            .onTapGesture(perform: actions)
    }
}

@available(OSX 10.15, *)
extension View {
    func addReactionOnInactiveWindowClick(actions: @escaping () -> Void) -> some View {
        self.modifier(AcceptMouseClick(actions: actions))
    }
}
