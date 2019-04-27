//
//  NSButton+Rx.swift
//  CoherentMac
//
//  Created by Loki on 7/4/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

#if os(macOS)
public extension Reactive where Base: NSButton {

    var title: ControlProperty<String> {
        return base.rx.controlProperty(
            getter: { $0.title },
            setter: { (control: NSButton, text: String) in control.title = text }
        )
    }
}
#endif
