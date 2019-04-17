//
//  TableViewBinder.swift
//  AppCore
//
//  Created by Loki on 4/17/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation

/////////////////////////////////////
/// CollectionService extension
////////////////////////////////////
public extension CollectionService where Entity : CollectionEntity {
    func tableViewBinder() -> TableViewBinder<Entity> {
        return TableViewBinder<Entity>(service: self)
    }
}


/////////////////////////////////////
/// TableViewBinder Binder Class
////////////////////////////////////
public class TableViewBinder<EntityType: CollectionEntity> {
    private var service         : CollectionService<EntityType>
    private var delegate        : NSTableViewDelegate?
    
    public init(service: CollectionService<EntityType>) {
        self.service = service
    }
    
    deinit {
        AppCore.log(title: "TableViewBinder", msg: "deinit")
    }
    
    public func set(delegate : NSTableViewDelegate?) -> TableViewBinder {
        self.delegate = delegate
        return self
    }
    
    public func bindTo<CellType>(view: NSTableView, cellId: String, cellType: CellType.Type, cellConfig: @escaping TableCellConfig<EntityType,CellType> = {_,_,_,_ in }) {
        let dataSource = TableViewDataSource<EntityType>(cellIdentifier: cellId, cellType: cellType, cellConfig: cellConfig)
        
        dataSource.delegate = delegate
        dataSource.bindWith(realmQuery: service.queryAllItems(), view: view)
    }
}

//public func collectionItemFactory<E: CollectionEntity, V: CollectionViewItem>(storyboard: NSStoryboard, id: String, service: CollectionService<E>, defaultImage: NSImage?, customConfig: CustomItemConfig<E,V>?) -> CollectionItemFactory<E> {
//    return { dataSource, view, indexPath, realmItem in
//        let item = storyboard.viewController(id: id) as! V
//
//        item.key        = realmItem.key
//        item.alias      = realmItem.alias
//        item.signals    = service.signals
//
//        if realmItem.iconPath.count > 0 {
//            item.image = NSImage(byReferencingFile: service.thumbnails.url.appendingPathComponent(realmItem.iconPath).path)
//        } else {
//            item.image = defaultImage
//        }
//
//        customConfig?(item,realmItem)
//
//        return item
//    }
//}
