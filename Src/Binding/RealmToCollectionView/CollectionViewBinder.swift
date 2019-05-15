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
public extension CollectionService where Entity : CollectionEntity {
    func collectionViewBinder() -> CollectionViewBinder<Entity> {
        return CollectionViewBinder<Entity>(service: self)
    }
}

/////////////////////////////////////
/// CollectionViewBinder Binder Class
////////////////////////////////////
public class CollectionViewBinder<EntityType: CollectionEntity> {
    private var service         : CollectionService<EntityType>
    private var defaultImage    : NSImage?
    private var delegate        : NSCollectionViewDelegate?
    
    public init(service: CollectionService<EntityType>) {
        self.service = service
    }
    
    deinit {
        AppCore.log(title: "CollectionServiceBinder", msg: "deinit")
    }
    
    public func setDefault(image: NSImage?) -> CollectionViewBinder {
        defaultImage = image
        return self
    }
    
    public func set(delegate : NSCollectionViewDelegate?) -> CollectionViewBinder {
        self.delegate = delegate
        return self
    }
    
    public func bindTo<ItemType>(view: NSCollectionView, itemId: String = "CollectionViewItem", config: @escaping CustomItemConfig<EntityType,ItemType> = {_,_ in }) {
        
        // prepare values to pass into closure
        let signals = service.signals
        let thumbnailsUrl = service.thumbnails.url
        let defaultImage = self.defaultImage
        
        let dataSource = CollectionViewDataSource<EntityType>(itemIdentifier: itemId, itemType: ItemType.self) { item, idx, realmItem  in
            item.key        = realmItem.key
            item.alias      = realmItem.alias
            item.signals    = signals
            
            if realmItem.iconPath.count > 0 {
                item.image = NSImage(byReferencingFile: thumbnailsUrl.appendingPathComponent(realmItem.iconPath).path)
            } else {
                item.image = defaultImage
            }
            
            config(item,realmItem)
        }
        
        dataSource.delegate = delegate
        dataSource.bindWith(collectionService: service, view: view)
    }
}
