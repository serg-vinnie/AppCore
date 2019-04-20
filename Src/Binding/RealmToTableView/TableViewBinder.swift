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
    private var cellConfigs     = [String:(NSTableCellView,EntityType)->Void]()
    
    public init(service: CollectionService<EntityType>) {
        self.service = service
    }
    
    deinit {
        AppCore.log(title: "TableViewBinder", msg: "deinit")
    }
    
    public func cell(id: String, block: @escaping (NSTableCellView,EntityType) -> Void) -> TableViewBinder {
        cellConfigs[id] = block
        
        return self
    }
    
    public func cellText(id: String, _ keyPath: KeyPath<EntityType, String>) -> TableViewBinder {
        cellConfigs[id] = { cellView, entity in
            cellView.textField?.stringValue = entity[keyPath: keyPath]
        }
        return self
    }
    
    public func cellText(id: String, _ text: String) -> TableViewBinder  {
        cellConfigs[id] = { cellView, entity in
            cellView.textField?.stringValue = text
        }
        return self
    }
    
    public func cellButton(id: String, block: @escaping (NSButton,EntityType)->Void) -> TableViewBinder {
        cellConfigs[id] = { cellView, entity in
            if let btn = cellView.subViews(type: NSButton.self).first {
                block(btn,entity)
            }
        }
        
        return self
    }
    
    public func cellButtonState(id:String, _ keyPath: ReferenceWritableKeyPath<EntityType, Bool>) -> TableViewBinder {
        cellConfigs[id] = { cellView, entity in
            if let btn = cellView.subViews(type: NSButton.self).first {
                btn.state = entity[keyPath: keyPath] ? .on : .off
                
                let key = entity.key
                
                btn.actionChannel().onUpdate(context: cellView) { [weak self] ctx, action in
                    guard let state = action.objectValue as? NSButton.StateValue else { return }

                    self?.service.db.updateObjectWith(key: key, ofType: EntityType.self) { obj in
                        obj[keyPath: keyPath] = (state == .on)
                    }
                }
            }
        }
        
        return self
    }
    
    public func set(delegate : NSTableViewDelegate?) -> TableViewBinder {
        self.delegate = delegate
        return self
    }
    
    public func bind(view: NSTableView) {
        let dataSource = TableViewDataSource<EntityType>(cellConfigs: cellConfigs)
        dataSource.delegate = delegate
        dataSource.bindWith(realmQuery: service.queryAllItems(), view: view)
    }
}
