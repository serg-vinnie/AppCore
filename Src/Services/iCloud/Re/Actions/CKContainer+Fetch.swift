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
    func fetch(token: CKServerChangeToken?) -> Channel<CKQueryNotification,CKServerChangeToken> {
        return producer() { producer in
            let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: token)
            
            operation.notificationChangedBlock = { notification in
                guard let notification = notification as? CKQueryNotification else { return }
                
                producer.update(notification)
            }
            
            operation.fetchNotificationChangesCompletionBlock = { newToken, error in
                if let error = error {
                    log(error: error)
                    producer.fail(error)
                } else if let token = newToken {
                    sleep(1) // TODO: remove it someday
                    log(msg: "new CHANGE TOKEN received \(token.debugDescription)")
                    producer.succeed(token)
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
