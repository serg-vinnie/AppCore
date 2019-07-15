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
                    promise.succeed(id)
                }
            }
        }
    }
}
