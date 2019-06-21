//
//  NSPopUpButton+Ninja.swift
//  AppCore
//
//  Created by Loki on 5/31/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja

public extension NSPopUpButton {
    
    typealias Data = ([(String,Int)],Int)
    
    static func localizedData<T : Hashable>(localizer: LocalizationState, selectedItem: T, items: [(String,Int)]) -> Data {
        let localizedItems = items.map { (localizer.stringBy(id: $0.0),$0.1) }
        return (localizedItems, selectedItem.hashValue)
    }
    
    func set(data: Data) {
        let (items, selectedItemTag) = data
        
        self.setItemsWithTags(items)
        self.selectItem(withTag: selectedItemTag)
        self.sizeToFit()
    }
    
    func setItemsWithTags(_ items: [(String,Int)]) {
        self.menu = createPopUpMenu(items: items)
    }
    
    func setItemWith(titles: [String]) {
        self.menu = createPopUpMenu(items: titles.enumerated().map { ($0.element, $0.element.count) })
    }
    
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

}
