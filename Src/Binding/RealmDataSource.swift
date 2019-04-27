//
//  RealmDataSource.swift
//  AppCore
//
//  Created by Loki on 4/27/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja
import RealmSwift

class RealmDataSource<EntityType: Object> : Ninja {
    private var realmQuery  : Results<EntityType>             // initial collection
    public  var items       : AnyRealmCollection<EntityType>  // filtered and sorted collection
    
    private var notificationToken: NotificationToken?
    
    private var sorting     = [NSSortDescriptor]()
    private var predicate   : NSPredicate?                    // filtering
    
    
    // output
    var producer = Producer<(AnyRealmCollection<EntityType>, RealmChangeset?), Void>()
    
    // input
    // CollectionSignal.Filter
    // CollectionSignal.Sort
    
    init(realmQuery: Results<EntityType>, signals: SignalsService) {
        self.realmQuery = realmQuery
        self.items = realmQuery.toAnyCollection()
        
        super.init()
        
        updateSubscription()
        
        signals.subscribeFor(CollectionSignal.Filter.self)
            .onUpdate(context: self) { ctx, signal in ctx.predicate = signal.predicate; ctx.updateSubscription() }
        signals.subscribeFor(CollectionSignal.Sort.self)
            .onUpdate(context: self) { ctx, signal in ctx.sorting = signal.descriptors; ctx.updateSubscription() }
    }
    
    func updateSubscription() {
        // apply sorting and filtering
        items = realmQuery.apply(sorting: sorting).apply(predicate: predicate).toAnyCollection()
        
        // update subscription
        notificationToken = items.observe { [weak producer] changeset in
            print("new changeset")
            switch changeset {
            case .initial(let value):
                producer?.update((value, nil))
            case .update(let value, let deletions, let insertions, let modifications):
                producer?.update((value, RealmChangeset(deleted: deletions, inserted: insertions, updated: modifications)))
            case .error(let error):
                producer?.fail(error)
            }
        }
    }
}

private extension Results {
    func apply(sorting: [NSSortDescriptor]) -> Results {
        return sorting.reduce(self) { results, sortDescriptor in results.apply(sorting: sortDescriptor) }
    }
    
    func apply(sorting: NSSortDescriptor) -> Results {
        if let key = sorting.key {
            return sorted(byKeyPath: key)
        }
        return self
    }

    func apply(predicate: NSPredicate?) -> Results {
        if let predicate = predicate {
            return self.filter(predicate)
        }
        return self
    }
}
