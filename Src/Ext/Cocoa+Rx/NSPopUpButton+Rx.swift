//
//  NSPopUpButton+Rx.swift
//  CoherentMac
//
//  Created by Loki on 5/29/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift
import RxCocoa

#if os(macOS)
public extension Reactive where Base: NSPopUpButton {
    
    private func createPopUpMenu(items: [(String,Int)]) -> NSMenu {
        let popupMenu = NSMenu()
        
        for (title,tag) in items {
            let menuItem = NSMenuItem()
            menuItem.title = title
            menuItem.tag = tag
            popupMenu.addItem(menuItem)
        }
        
        return popupMenu
    }
    
    func setEnumeratedItemsFrom(array: [String]) {
        Observable.just(array.enumerated().map { ($0.element, $0.offset) })
            .bind(to: menuItems)
            .dispose()
    }
    
    var menuItems: Binder<[(String,Int)]> {
        return Binder(self.base) { (owner, value) in
            owner.menu = self.createPopUpMenu(items: value)
        }
    }

    /// Reactive wrapper for control event.
    var itemSelectedTag: ControlProperty<Int> {
        return base.rx.controlProperty(
            getter: { control in
                guard let item = control.selectedItem else { return -1 }
                return item.tag },
            setter: { (control: NSPopUpButton, tag: Int) in
                control.select(control.menu?.items.first(where: { $0.tag == tag })) }
        )
    }
    

}
#endif
