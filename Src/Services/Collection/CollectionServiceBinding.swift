//
//  CollectionServiceBinding.swift
//  AppCore
//
//  Created by Loki on 4/15/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import RealmSwift

public extension CollectionService {
    func bindTo(view: NSCollectionView, itemId: String, storyboard: NSStoryboard, defaultImage: String, delegate: NSCollectionViewDelegate) {
        let dataSource = CollectionViewDataSource<Entity>(
            itemFactory: collectionItemFactory(storyboard: storyboard, id: itemId, service: self, defaultImage: defaultImage))
        
        dataSource.delegate = delegate
        dataSource.bindWith(realmQuery: self.queryAllItems(), view: view)
    }
}

public func collectionItemFactory<E: CollectionEntity>(storyboard: NSStoryboard, id: String, service: CollectionService<E>, defaultImage: String) -> CollectionItemFactory<E> {
    return { dataSource, view, indexPath, realmItem in
        let item = storyboard.viewController(id: id) as! CollectionViewItem
        let realmItem = realmItem as CollectionEntityProtocol
        
        item.key        = realmItem.key
        item.alias      = realmItem.alias
        item.signals    = service.signals
        
        if realmItem.iconPath.count > 0 {
            item.image = NSImage(byReferencingFile: service.thumbnails.url.appendingPathComponent(realmItem.iconPath).path)
        } else {
            item.image = NSImage(named: defaultImage)
        }
        
        return item
    }
}
