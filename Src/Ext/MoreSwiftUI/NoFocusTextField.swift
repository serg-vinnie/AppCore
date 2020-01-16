//
//  NoFocusTextField.swift
//  AppCore
//
//  Created by UKS_neo on 29.12.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import SwiftUI
import Cocoa


@available(OSX 10.15, *)
public struct AttributedText: NSViewRepresentable {
    var text: NSAttributedString

    public init(attributedString: NSAttributedString) {
        self.text = attributedString
    }
    
    public init(string: String) {
        self.text = NSAttributedString(string: string)
    }
    
    public func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(labelWithAttributedString: text)
        //let textField = NSTextField(string: String( text.string ) )
        //textField.sizeToFit()
        
//        let bstHeight = textField.bestHeight(for: text.string , width: 10000)
//        let bstWidth = textField.bestWidth(for: text.string , height: bstHeight)
//        textField.setBoundsSize(NSSize(width: bstWidth , height: bstHeight) )
        
        textField.backgroundColor = NSColor.brown
        
        // no necessity in coordinator for read-only control
        // textField.delegate = context.coordinator
        
        textField.isBordered = true
        textField.layer?.borderColor = NSColor.black.cgColor
        textField.layer?.borderWidth = 1.0

//        textField.backgroundColor = nil
//        textField.focusRingType = .none
        //textField.isSelectable = true
        return textField
    }
    
    public func updateNSView(_ nsView: NSTextField, context: Context) {
        //nsView.attributedString //= NSAttributedString()
        //nsView.attributedString = _text
    }
}



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



extension NSTextField {
    func bestHeight(for text: String, width: CGFloat) -> CGFloat {
        stringValue = text
        let height = cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)).height

        return height
    }

    func bestWidth(for text: String, height: CGFloat) -> CGFloat {
        stringValue = text
        let width = cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height)).width

        return width
    }
    
    func bla() -> CGFloat {
        self.font!.pointSize
    }
}
