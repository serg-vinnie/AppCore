//
//  NoFocusTextField.swift
//  AppCore
//
//  Created by UKS_neo on 29.12.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import SwiftUI

@available(OSX 10.15, *)
public struct NoFocusTextField: NSViewRepresentable {
    @Binding var text: String

    public init(text: Binding<String>) {
        _text = text
    }

    public func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: text)
        textField.delegate = context.coordinator
        textField.isBordered = false
        textField.backgroundColor = nil
        textField.focusRingType = .none
        return textField
    }

    public func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator { self.text = $0 }
    }

    
}

public final class Coordinator: NSObject, NSTextFieldDelegate {
    var setter: (String) -> Void

    init(_ setter: @escaping (String) -> Void) {
        self.setter = setter
    }

    public func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            setter(textField.stringValue)
        }
    }
}
