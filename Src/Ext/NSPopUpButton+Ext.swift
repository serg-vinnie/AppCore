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
    typealias ChannelsSet = (Channel<String?, Void>?, Channel<NSPopUpButton.Data, Void>?, Channel<String?, Void>?)
    
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


public extension NinjaContext.Main {
    func popUpTrio<T : Hashable>(titleId: String, values: [(String,Int)], descriptions: [Int:String], didChange: Channel<T, Void>) -> NSPopUpButton.ChannelsSet {
        let title = AppCore.states.localizationDidChange
            .map(context: self) { _, localizer in localizer.stringBy(id: titleId) as String? }
        
        let data = self.combineLatest(AppCore.states.localizationDidChange, didChange)
            .map(context: self) { _, arg in NSPopUpButton.localizedData(localizer: arg.0, selectedItem: arg.1, items: values) }
            .mapSuccess { _,_ in () }
        
        let descriptions = self.combineLatest(AppCore.states.localizationDidChange, didChange)
            .map(context: self) { _, args in args.0.stringBy(id: descriptions[args.1.hashValue]!) as String? }
            .mapSuccess() { _,_ in () }
        
        return (title, data, descriptions)
    }
}
