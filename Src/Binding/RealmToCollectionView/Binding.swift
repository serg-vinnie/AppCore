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

public func bind33<E>(realmQuery: Results<E>, dataSource: AsyncCollectionViewDataSource<E>, view: NSCollectionView) {
    changesetChannel(from: realmQuery)
        .bind(createSinkWith(dataSource: dataSource, to: view))
}

public func createSinkWith<E>(dataSource: AsyncCollectionViewDataSource<E>, to view: NSCollectionView) -> Sink<(AnyRealmCollection<E>,RealmChangeset?),Void> {
    
    return createSinkWith(dataSource: dataSource) { ds, results, changes in
        if ds.collectionView == nil {
            ds.collectionView = view
        }
        ds.collectionView?.dataSource = ds
        ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
    }
}

func createSinkWith<E>(dataSource: AsyncCollectionViewDataSource<E>, block: @escaping (AsyncCollectionViewDataSource<E>, AnyRealmCollection<E>, RealmChangeset?) -> Void)
    -> Sink<(AnyRealmCollection<E>,RealmChangeset?),Void> {
        
        return Sink(updateExecutor: Executor.main) { sink, event, executor in
            if case let .update(element) = event {
                block(dataSource, element.0, element.1)
            }
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
        producer._asyncNinja_notifyFinalization { print("Realm subscription released") }
    }
}
