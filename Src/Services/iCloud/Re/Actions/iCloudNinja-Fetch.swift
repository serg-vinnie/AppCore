//
//  iCloudNinja-Fetch.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

func iCloudNinjaFetch(ids: [CKRecord.ID], cloudDB: CKDatabase) -> Future<[CKRecord.ID:CKRecord]> {
    let promise = Promise<[CKRecord.ID:CKRecord]>()
    
    let fetch = CKFetchRecordsOperation(recordIDs: ids)
    fetch.fetchRecordsCompletionBlock = { records, error in
        if let records = records        { promise.succeed(records) }
        if let error = error            { log(error: error); promise.fail(error) }
    }
    cloudDB.add(fetch)
    
    return promise
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinjaFetch(records:", error: error)
}
