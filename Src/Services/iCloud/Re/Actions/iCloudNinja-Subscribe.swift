//
//  iCloudNinja-Subscribe.swift
//  AppCore
//
//  Created by Loki on 7/10/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKDatabase {
    func subscribe(_ subscription: CKSubscription) -> Future<CKSubscription> {
        return promise() { promise in
            self.save(subscription) { subscription, error in
                if let error = error {
                    log(error: error)
                    promise.fail(error)
                }
                if let subscription = subscription {
                    log(msg: "subscribed to \(subscription.subscriptionID)")
                    promise.succeed(subscription)
                }
            }
        }
    }
    
    func fetchAllSubscriptions() -> Future<[CKSubscription]> {
        return promise() { promise in
            self.fetchAllSubscriptions { subscriptions, error in
                if let error = error {
                    log(error: error)
                    promise.fail(error)
                }
                
                if let subscriptions = subscriptions {
                    log(msg: "fetched \(subscriptions.count) subscriptions")
                    promise.succeed(subscriptions)
                }
            }
        }
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}
