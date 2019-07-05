//
//  iCloudNinja-Delete.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

func iCloudNinjaDelete(IDs: [CKRecord.ID], batchSize: Int, cloudDB: CKDatabase) -> Channel<[CKRecord.ID],Void> {
    return producer() { producer in
        let delete =  CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
        delete.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
            if let IDs = deletedRecordIDs   { log(msg: "\(IDs.count) deleted"); producer.update(IDs); producer.succeed(()) }
            if let error = error            { log(error: error); producer.fail(error) }
        }
        
        cloudDB.add(delete)
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}
