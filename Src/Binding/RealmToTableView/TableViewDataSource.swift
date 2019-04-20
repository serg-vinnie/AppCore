//
//  TableViewDataSource.swift
//  AppCore
//
//  Created by Loki on 4/17/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift
import Realm

public typealias TableCellFactory<EntityType: Object> = (NSTableView, Int, String?, EntityType) -> NSTableCellView

open class TableViewDataSource<EntityType: Object>: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private var items: AnyRealmCollection<EntityType>?
    
    // MARK: - Configuration
    public var tableView: NSTableView?
    public var animated = true
    public var rowAnimations = (
        insert: NSTableView.AnimationOptions.effectFade,
        update: NSTableView.AnimationOptions.effectFade,
        delete: NSTableView.AnimationOptions.effectFade)
    
    public weak var delegate: NSTableViewDelegate?
    public weak var dataSource: NSTableViewDataSource?
    
    public let cellFactory: TableCellFactory<EntityType>
    
    public init(cellConfigs : [String:(NSTableCellView,EntityType)->Void]) {
        cellFactory = { tableView, row, column, entity in
            guard
                let id = column, 
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: tableView) as? NSTableCellView,
                let config = cellConfigs[id]
                else { return NSTableCellView() }
            
            config(cell,entity)
            
            return cell
        }
    }
    
    // MARK: - UITableViewDataSource protocol
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return items?.count ?? 0
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnId = tableColumn?.identifier.rawValue
        return cellFactory(tableView, row, columnId, items![row])
    }
    
    // MARK: - Proxy unimplemented data source and delegate methods
    open override func responds(to aSelector: Selector!) -> Bool {
        if TableViewDataSource.instancesRespond(to: aSelector) {
            return true
        } else if let delegate = delegate {
            return delegate.responds(to: aSelector)
        } else if let dataSource = dataSource {
            return dataSource.responds(to: aSelector)
        } else {
            return false
        }
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegate ?? dataSource
    }
    
    // MARK: - Applying changeset to the table view
    private let fromRow = {(row: Int) in return IndexPath(item: row, section: 0)}
    
    func applyChanges(items: AnyRealmCollection<EntityType>, changes: RealmChangeset?) {
        if self.items == nil {
            self.items = items
        }
        
        guard let tableView = tableView else {
            fatalError("You have to bind a table view to the data source.")
        }
        
        guard animated else {
            tableView.reloadData()
            return
        }
        
        guard let changes = changes else {
            tableView.reloadData()
            return
        }
        
        let lastItemCount = tableView.numberOfRows
        guard items.count == lastItemCount + changes.inserted.count - changes.deleted.count else {
            tableView.reloadData()
            return
        }
        
        tableView.beginUpdates()
        tableView.removeRows(at: IndexSet(changes.deleted), withAnimation: rowAnimations.delete)
        tableView.insertRows(at: IndexSet(changes.inserted), withAnimation: rowAnimations.insert)
        tableView.reloadData(forRowIndexes: IndexSet(changes.updated), columnIndexes: IndexSet([0]))
        tableView.endUpdates()
    }
}
