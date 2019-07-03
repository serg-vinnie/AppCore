//
//  ReCloud-Push.swift
//  SwiftCore
//
//  Created by Loki on 1/10/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

func iCloudNinjaPush(records: [CKRecord], cloudDB: CKDatabase) -> Future<[CKRecord]> {
    let promise = Promise<[CKRecord]>()
    let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
    operation.modifyRecordsCompletionBlock = { records, _, error in
        if let error = error            { log(error: error); promise.fail(error) }
        if let records = records        { promise.succeed(records) }
    }
    cloudDB.add(operation)
    
    return promise
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error, thread: true)
}
