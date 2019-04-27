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

extension CollectionViewDataSource {
    public func bindWith(realmQuery: Results<E>, view: NSCollectionView) {
        self.collectionView = view
        view.dataSource = self
        view.delegate = self
        
        // IMPORTANT!!!!
        // this subscription is owned by NSCollectionView
        // reference to self is captured by closure
        
        changesetChannel(from: realmQuery)
            .onUpdate(context: view, executor: .immediate)
                { _, update in self.applyChanges(items: update.0, changes: update.1)}
    }
}

extension TableViewDataSource where EntityType : CollectionEntity {
    public func bindWith(collectionService: CollectionService<EntityType>, view: NSTableView)  {
        self.tableView = view
        view.dataSource = self
        view.delegate = self
        
        self.signals = collectionService.signals
        
        realmData = RealmDataSource(realmQuery: collectionService.queryAllItems(), signals: collectionService.signals)
        
        // IMPORTANT!!!!
        // this subscription is owned by NSTableView
        // reference to self is captured by closure
        realmData?.producer
            .onUpdate(context: view, executor: .immediate) { _, update in self.applyChanges(items: update.0, changes: update.1)}
            ._asyncNinja_notifyFinalization { print("TableViewDataSource subscription finalize") }
    }
}

public struct RealmChangeset {
    /// the indexes in the collection that were deleted
    public let deleted: [Int]
    
    /// the indexes in the collection that were inserted
    public let inserted: [Int]
    
    /// the indexes in the collection that were modified
    public let updated: [Int]
    
    public init(deleted: [Int], inserted: [Int], updated: [Int]) {
        self.deleted = deleted
        self.inserted = inserted
        self.updated = updated
    }
}

public func changesetChannel<E: Object>(from collection: Results<E>) -> Channel<(AnyRealmCollection<E>, RealmChangeset?), Void> {
    
    return producer() { producer in
        let notificationToken = collection.toAnyCollection().observe { /*do not forget*/ [weak producer] changeset in
            switch changeset {
            case .initial(let value):
                producer?.update((value, nil))
            case .update(let value, let deletions, let insertions, let modifications):
                producer?.update((value, RealmChangeset(deleted: deletions, inserted: insertions, updated: modifications)))
            case .error(let error):
                producer?.fail(error)
            }
        }
        
        producer._asyncNinja_retainUntilFinalization(notificationToken)
        producer._asyncNinja_notifyFinalization { AppCore.log(title: "RealmChangeset", msg: "subscription released") }
    }
}


// to delete >>
func apply<E: Object>(sorting: [NSSortDescriptor], to collection: Results<E>) -> Results<E> {
    var result = collection
    for item in sorting {
        result = apply(sorting: item, to: result)
    }
    return result
}

func apply<E: Object>(sorting: NSSortDescriptor, to collection: Results<E>) -> Results<E> {
    if let key = sorting.key {
        print("adding sorting by \(key) acending: \(sorting.ascending)")
        return collection.sorted(byKeyPath: key, ascending: sorting.ascending)
    } else {
        return collection
    }
}
