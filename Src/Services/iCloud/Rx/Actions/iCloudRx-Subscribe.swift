//
//  iCloudRx-Subscribe.swift
//  KeyKey
//
//  Created by Loki on 5/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import RxSwift
import CloudKit

func iCloudRxSubscribe(to subscription: CKSubscription, cloudDB: CKDatabase) -> Observable<CKSubscription> {
    return Observable<CKSubscription>.create { observer in
             
        cloudDB.save(subscription) { subscription, error  in
            if let error = error {
                observer.onError(error)
            }
            if let s = subscription {
                observer.onNext(s)
            }
            observer.onCompleted()
        }
        
        return Disposables.create()
    }
}

func iCloudRxUnsubscribe(from subscriptionID: String, cloudDB: CKDatabase) -> Observable<String> {
    return Observable<String>.create { subscribe in
        
        cloudDB.delete(withSubscriptionID: subscriptionID) { id, error in
            if let error = error    { subscribe.onError(error) }
            if let id = id          { subscribe.onNext(id) }
            subscribe.onCompleted()
        }
        return Disposables.create()
    }
}

func iCloudRxFetchSubscriptions(cloudDB: CKDatabase) -> Observable<CKSubscription> {
    return Observable<CKSubscription>.create { subscribe in
        
        cloudDB.fetchAllSubscriptions { subscriptions, error in
            if let error = error {
                subscribe.onError(error)
            }
            if let items = subscriptions {
                for item in items {
                    subscribe.onNext(item)
                }
            }
            subscribe.onCompleted()
        }
        
        return Disposables.create()
    }
}

func iCloudRxDeleteSubscriptions(cloudDB: CKDatabase, IDs: [String]) -> Observable<[String]?> {
    return Observable<([String]?)>.create { subscribe in
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: IDs)
        
        operation.modifySubscriptionsCompletionBlock = { _, deleted, error in
            if let error = error { subscribe.onError(error) }
            subscribe.onNext(deleted)
            subscribe.onCompleted()
        }
        cloudDB.add(operation)
        return Disposables.create()
    }
}

func iCloudRxModifySubscriptions(cloudDB: CKDatabase, toSave: [CKSubscription], toDelete: [String]) -> Observable<([CKSubscription]?,[String]?)> {
    return Observable<([CKSubscription]?,[String]?)>.create { subscribe in
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: toSave, subscriptionIDsToDelete: toDelete)
        
        operation.modifySubscriptionsCompletionBlock = { saved, deleted, error in
            if let error = error { subscribe.onError(error) }
            subscribe.onNext((saved,deleted))
            subscribe.onCompleted()
        }
        cloudDB.add(operation)
        return Disposables.create()
    }
}

