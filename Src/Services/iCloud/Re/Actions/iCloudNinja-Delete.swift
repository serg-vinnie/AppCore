//
//  iCloudNinja-Delete.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

func iCloudNinjaDelete(IDs: [CKRecord.ID], batchSize: Int, cloudDB: CKDatabase) -> Future<[CKRecord.ID]> {
    let promise = Promise<[CKRecord.ID]>()
    
    let delete =  CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
    delete.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
        if let IDs = deletedRecordIDs   { promise.succeed(IDs) }
        if let error = error            { log(error: error); promise.fail(error) }
    }
    
    cloudDB.add(delete)
    
    return promise
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}
