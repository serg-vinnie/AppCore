//
//  CollectionDelegate.swift
//  TaoGit
//
//  Created by Loki on 1/27/19.
//  Copyright © 2019 Cheka Zuja. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift
import Realm
import AsyncNinja

public typealias CollectionItemFactory<EntityType: Object> = (CollectionViewDataSource<EntityType>, NSCollectionView, IndexPath, EntityType) -> NSCollectionViewItem
public typealias CollectionItemConfig<EntityType: Object, ItemType: NSCollectionViewItem> = (ItemType, IndexPath, EntityType) -> Void

public class CollectionViewDataSource<EntityType: Object>: NSObject, NSCollectionViewDelegate, NSCollectionViewDataSource {
    var realmData: RealmDataSource<EntityType>?
    var signals: SignalsService?
    var items: AnyRealmCollection<EntityType>?
    
    // MARK: - Configuration
    public weak var collectionView: NSCollectionView?
    public var animated = true
    
    // MARK: - Init
    public let itemFactory: CollectionItemFactory<EntityType>
    
    public weak var delegate: NSCollectionViewDelegate?
    public weak var dataSource: NSCollectionViewDataSource?
    
    public init(itemFactory: @escaping CollectionItemFactory<EntityType>) {
        self.itemFactory = itemFactory
    }
    
    public init<ItemType>(itemIdentifier: String, itemType: ItemType.Type, itemConfig: @escaping CollectionItemConfig<EntityType, ItemType>) where ItemType: NSCollectionViewItem {
        self.itemFactory = { ds, cv, ip, model in
            let item = cv.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: itemIdentifier), for: ip) as! ItemType
            itemConfig(item, ip, model)
            return item
        }
    }
    
    deinit {
        AppCore.log(title: "CollectionViewDataSource", msg: "deinit")
    }
    
    // MARK: - NSCollectionViewDataSource protocol
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return itemFactory(self, collectionView, indexPath, items![indexPath.item])
    }
    
    // MARK: - Proxy unimplemented data source and delegate methods
    open override func responds(to aSelector: Selector!) -> Bool {
        if CollectionViewDataSource.instancesRespond(to: aSelector) {
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
    
    // MARK: - Applying changeset to the collection view
    private let fromRow = {(row: Int) in return IndexPath(item: row, section: 0)}
    
    func applyChanges(items: AnyRealmCollection<EntityType>, changes: RealmChangeset?) {
        
        self.items = items
        
        guard let collectionView = collectionView else {
            fatalError("You have to bind a collection view to the data source.")
        }
        
        guard animated else {
            collectionView.reloadData()
            return
        }
        
        guard let changes = changes else {
            let itemsCount = items.count
            collectionView.reloadData()
            DispatchQueue.main.async { [weak signals] in
                signals?.send(signal: Signal.Collection.DidLoadFirstData(itemsCount: itemsCount))
            }
            return
        }
        
        let lastItemCount = collectionView.numberOfItems(inSection: 0)
        guard items.count == lastItemCount + changes.inserted.count - changes.deleted.count else {
            collectionView.reloadData()
            return
        }
        
        collectionView.performBatchUpdates({[unowned self] in
            //TODO: this should be animated, but doesn't seem to be?
            //NSAnimationContext.current.duration = 1.0
            
            collectionView.animator().deleteItems(at: Set(changes.deleted.map(self.fromRow)))
            collectionView.animator().reloadItems(at: Set(changes.updated.map(self.fromRow)))
            collectionView.animator().insertItems(at: Set(changes.inserted.map(self.fromRow)))
            }, completionHandler: nil)
    }
    
}


