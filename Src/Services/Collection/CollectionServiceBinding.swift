//
//  CollectionServiceBinding.swift
//  AppCore
//
//  Created by Loki on 4/15/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import RealmSwift

public typealias CustomItemConfig<EntityType: CollectionEntity, ItemType: CollectionViewItem> = (ItemType, EntityType) -> Void

/////////////////////////////////////
/// CollectionService extension
////////////////////////////////////
public extension CollectionService {
    func binder() -> CollectionServiceBinder<Entity,CollectionViewItem> {
        return CollectionServiceBinder(service: self)
    }
}

/////////////////////////////////////
/// CollectionService Binder Class
////////////////////////////////////
public class CollectionServiceBinder<EntityType: CollectionEntity, ItemType: CollectionViewItem> {
    private var service         : CollectionService<EntityType>
    private var customConfig    : CustomItemConfig<EntityType,ItemType>?
    private var defaultImage    : NSImage?
    private var delegate        : NSCollectionViewDelegate?
    
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
            itemFactory: collectionItemFactory(storyboard: storyboard, id: itemId, service: service, defaultImage: defaultImage, customConfig: customConfig))
        dataSource.delegate = delegate
        dataSource.bindWith(realmQuery: service.queryAllItems(), view: view)
    }
}

public func collectionItemFactory<E: CollectionEntity, V: CollectionViewItem>(storyboard: NSStoryboard, id: String, service: CollectionService<E>, defaultImage: NSImage?, customConfig: CustomItemConfig<E,V>?) -> CollectionItemFactory<E> {
    return { dataSource, view, indexPath, realmItem in
        let item = storyboard.viewController(id: id) as! V
        
        item.key        = realmItem.key
        item.alias      = realmItem.alias
        item.signals    = service.signals
        
        if realmItem.iconPath.count > 0 {
            item.image = NSImage(byReferencingFile: service.thumbnails.url.appendingPathComponent(realmItem.iconPath).path)
        } else {
            item.image = defaultImage
        }
        
        customConfig?(item,realmItem)
        
        return item
    }
}
