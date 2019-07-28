//
//  Binding.swift
//  AppCore
//
//  Created by Loki on 3/30/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja
import RealmSwift

extension CollectionViewDataSource where EntityType : Object, EntityType: CollectionBaseEntity {
    public func bindWith(collectionService: CollectionService<EntityType>, view: NSCollectionView) {
        self.collectionView = view
        view.dataSource = self
        view.delegate = self
        
        self.signals = collectionService.signals
        
        realmData = RealmDataSource(realmQuery: collectionService.queryAllItems(), signals: collectionService.signals)
        
        // IMPORTANT!!!!
        // this subscription is owned by NSCollectionView
        // reference to self is captured by closure
        realmData?.stream
            .onUpdate(context: view, executor: .immediate) { _, update in self.applyChanges(items: update.0, changes: update.1)}
            ._asyncNinja_notifyFinalization { print("TableViewDataSource subscription finalize") }
    }
}

extension TableViewDataSource where EntityType : CollectionBaseEntity {
    public func bindWith(collectionService: CollectionService<EntityType>, view: NSTableView)  {
        self.tableView = view
        view.dataSource = self
        view.delegate = self
        
        self.signals = collectionService.signals
        
        realmData = RealmDataSource(realmQuery: collectionService.queryAllItems(), signals: collectionService.signals)
        
        // IMPORTANT!!!!
        // this subscription is owned by NSTableView
        // reference to self is captured by closure
        realmData?.stream
            .onUpdate(context: view, executor: .immediate) { _, update in self.applyChanges(items: update.0, changes: update.1)}
            ._asyncNinja_notifyFinalization { print("TableViewDataSource subscription finalize") }
    }
}
