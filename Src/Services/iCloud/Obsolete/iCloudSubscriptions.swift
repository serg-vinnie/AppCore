//
//  iCloudSubscriptions.swift
//  KeyKey
//
//  Created by Loki on 3/29/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit

open class iCloudSubscriptions {
    private(set) var cloudDB        : CKDatabase
    private(set) var subscriptions  = [CKSubscription]()
    private(set) var wasFetched     = false
    public       var count          : Int { return subscriptions.count }
    
    public var dbgSummary: String { return "subscriptions count \(count)" }
    
    public init(cloudDB: CKDatabase){
        self.cloudDB = cloudDB
    }
    
    public func sync(onComplete: @escaping (Bool)->Void) {
        fetch { success in
            print("KKCloud subscriptions fetch: \(success) ")
            print("KKCloud subscriptions count: \(self.subscriptions.count) ")
            if success {
                if self.subscriptions.count > 0 {
                    onComplete(true)
                } else {
                    self.subscribe { success in
                        print("KKCloud subscribe: \(success) ")
                        onComplete(success)
                    }
                }
            } else {
                onComplete(false)
            }
        }
    }
    
    open func subscribe(onComplete: @escaping (Bool)->Void) { // override me
        onComplete(false)
        assert(false, "override me")
    }

    
    public func fetch(onComplete: @escaping (Bool)->Void) {
        cloudDB.fetchAllSubscriptions { subscriptions, error in
            if let error = error {
                print("fetchAllSubscriptions error: \(error)")
                onComplete(false)
            }
            
            if let items = subscriptions {
                self.subscriptions = items
            }
            self.wasFetched = self.subscriptions.count > 0
            onComplete(true)
        }
    }
    
    public func subscribe(to subscription: CKSubscription, onComplete: @escaping (Bool)->Void) {
        cloudDB.save(subscription) { subscription, error  in
            if let error = error {
                print("save subscription error: \(error)")
                onComplete(false)
            } else {
                if let s = subscription {
                    self.subscriptions.append(s)
                }
                onComplete(true)
            }
        }
    }
    
    public func unsubscribeFrom(_ subscription: CKSubscription, onComplete: @escaping (Bool)->Void) {
        cloudDB.delete(withSubscriptionID: subscription.subscriptionID) { id, error in
            if let error = error {
                print("delete subscription error: \(error)")
            }
            
            if let id = id {
                if let index = self.subscriptions.firstIndex(of: subscription) {
                    self.subscriptions.remove(at: index)
                }
                print("subscription deleted \(id)")
                
            }
            
            onComplete(error == nil)
        }
    }
    
    public func unsubscribeFromAll(onComplete: @escaping (Bool)->Void) {
        let subIDs = subscriptions.map { $0.subscriptionID }
        let delete = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: subIDs)
        
        delete.modifySubscriptionsCompletionBlock = { _, deletedIDs, error in
            if let error = error {
                print("iCloud unsubscribeFromAll error : \(error)")
            }
            if let ids = deletedIDs {
                for id in ids {
                    if let idx = self.subscriptions.firstIndex(where: { $0.subscriptionID == id }) {
                        self.subscriptions.remove(at: idx)
                    }
                }
            }
            onComplete(error == nil)
        }
        
        cloudDB.add(delete)
    }
    
}
