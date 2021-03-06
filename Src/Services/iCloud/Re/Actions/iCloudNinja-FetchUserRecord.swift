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
        return promise(executor: .iCloud) { [weak self] promise in
            self?.fetchUserRecordID { recordID, error in
                if let error = error {
                    promise.fail(error)
                }
                if let id = recordID {
                    AppCore.log(title: "iCloudNinja", msg: "user id did fetch \(id.recordName)")
                    promise.succeed(id)
                }
            }
        }
    }
}
