//
//  iCludNinja-FetchChanges.swift
//  AppCore
//
//  Created by Loki on 7/8/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKContainer {
    func fetch(token: CKServerChangeToken?, executor: Executor) -> Channel<CKQueryNotification,CKServerChangeToken> {
        return producer(executor: executor) { producer in
            let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: token)
            
            operation.notificationChangedBlock = { notification in
                guard let notification = notification as? CKQueryNotification else { return }
                
                producer.update(notification, from: executor)
            }
            
            operation.fetchNotificationChangesCompletionBlock = { newToken, error in
                if let error = error {
                    log(error: error)
                    producer.fail(error, from: executor)
                } else if let token = newToken {
                    log(msg: "new CHANGE TOKEN received \(token.debugDescription)")
                    producer.succeed(token, from: executor)
                }
            }
            
            self.add(operation)
        }
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}
