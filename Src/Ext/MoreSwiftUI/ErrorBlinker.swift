//
//  ErrorBlinker.swift
//  AppCore
//
//  Created by UKS_neo on 29.12.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import SwiftUI
import Combine

@available(OSX 10.15, *)
public extension View {
    func addErrorBlinker<T: Publisher>(subscribedTo publisher: T, duration: Double = 0.5)
        -> some View where T.Output == Void, T.Failure == Never {

            self.modifier(ErrorBlinker(subscribedTo: publisher.eraseToAnyPublisher(),
                                         duration: duration))
    }
}

@available(OSX 10.15, *)
struct ErrorBlinker: ViewModifier {
    @State private var blinker = false
    
    var publisher: AnyPublisher<Void, Never>
    var duration: Double

    init(subscribedTo publisher: AnyPublisher<Void, Never>, duration: Double = 1) {
        self.publisher = publisher
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .background(blinker ? Color(rgbaHex: 0xff222277) : Color.clear)
            .onReceive(publisher) { _ in
                withAnimation(.linear(duration: self.duration / 2)) {
                    self.blinker = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.duration / 2) {
                        withAnimation(.linear(duration: self.duration / 2)) {
                            self.blinker = false
                        }
                    }
                }
            }
            .blur(radius: blinker ? 7 : 0)
            .onReceive(publisher) { _ in
                withAnimation(.linear(duration: self.duration / 2)) {
                    self.blinker = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.duration / 2) {
                        withAnimation(.linear(duration: self.duration / 2)) {
                            self.blinker = false
                        }
                    }
                }
            }
    }
}
