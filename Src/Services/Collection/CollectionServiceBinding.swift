//
//  CollectionServiceBinding.swift
//  AppCore
//
//  Created by Loki on 4/15/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import RealmSwift

public typealias CustomItemConfig<EntityType: CollectionEntity, ItemType: NSCollectionViewItem> = (ItemType, EntityType) -> Void

public class CollectionServiceBinder<EntityType: CollectionEntity, ItemType: NSCollectionViewItem> {
    private var service         : CollectionService<EntityType>
    private var customConfig    : CustomItemConfig<EntityType,ItemType>?
    private var defaultImage    : NSImage?
    private var delegate   : NSCollectionViewDelegate?
    
    public init(service: CollectionService<EntityType>) {
        self.service = service
    }
    
    deinit {
        AppCore.log(title: "CustomItemConfig", msg: "deinit")
    }
    
    public func setCustomConfig(_ config: @escaping CustomItemConfig<EntityType,ItemType>) -> CollectionServiceBinder {
        customConfig = config
        return self
    }
    
    public func setDefault(image: NSImage?) -> CollectionServiceBinder {
        defaultImage = image
        return self
    }
    
    public func set(delegate : NSCollectionViewDelegate?) -> CollectionServiceBinder {
        self.delegate = delegate
        return self
    }
    
    public func bindTo(view: NSCollectionView, itemId: String, storyboard: NSStoryboard) {
        let dataSource = CollectionViewDataSource<EntityType>(
            itemFactory: collectionItemFactory(storyboard: storyboard, id: itemId, service: service, defaultImage: defaultImage))
        dataSource.delegate = delegate
        dataSource.bindWith(realmQuery: service.queryAllItems(), view: view)
    }
    
    
}

public extension CollectionService {
    func bindTo(view: NSCollectionView, itemId: String, storyboard: NSStoryboard, defaultImage: NSImage?, delegate: NSCollectionViewDelegate) {
        let dataSource = CollectionViewDataSource<Entity>(
            itemFactory: collectionItemFactory(storyboard: storyboard, id: itemId, service: self, defaultImage: defaultImage))
        
        dataSource.delegate = delegate
        dataSource.bindWith(realmQuery: self.queryAllItems(), view: view)
    }
}

public func collectionItemFactory<E: CollectionEntity>(storyboard: NSStoryboard, id: String, service: CollectionService<E>, defaultImage: NSImage?) -> CollectionItemFactory<E> {
    return { dataSource, view, indexPath, realmItem in
        let item = storyboard.viewController(id: id) as! CollectionViewItem
        let realmItem = realmItem as CollectionEntityProtocol
        
        item.key        = realmItem.key
        item.alias      = realmItem.alias
        item.signals    = service.signals
        
        if realmItem.iconPath.count > 0 {
            item.image = NSImage(byReferencingFile: service.thumbnails.url.appendingPathComponent(realmItem.iconPath).path)
        } else {
            item.image = defaultImage
        }
        
        return item
    }
}