//
//  iCloudNinja-FetchUserRecord.swift
//  AppCore
//
//  Created by Loki on 7/15/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKContainer {
    func userRecordID() -> Future<CKRecord.ID> {
        return promise() { [weak self] promise in
            self?.fetchUserRecordID { recordID, error in
                if let error = error {
                    promise.fail(error)
                }
                if let id = recordID {
                    AppCore.log(title: "iCloudNinja", msg: "user id did fetch (future) \(id.recordName)")
                    promise.succeed(id)
                }
            }
        }
    }
    
    func userRecordID() -> Channel<CKRecord.ID, Void> {
        return producer() { [weak self] producer in
            self?.fetchUserRecordID { recordID, error in
                if let error = error {
                    producer.fail(error)
                }
                if let id = recordID {
                    AppCore.log(title: "iCloudNinja", msg: "user id did fetch (channel) \(id.recordName)")
                    producer.update(id)
                    producer.succeed()
                }
            }
        }
    }
}
