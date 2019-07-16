//
//  iCloudNinja-Delete.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKDatabase {
    func delete(IDs: [CKRecord.ID]) -> Channel<[CKRecord.ID],Void> {
        log(msg: "going to delete \(IDs.count) records")
        return producer() { producer in
            let delete =  CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
            delete.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
                // TODO: remove sleep(1) someday
                if let IDs = deletedRecordIDs   { log(msg: "\(IDs.count) deleted"); producer.update(IDs); sleep(1); producer.succeed(()) }
                if let error = error            { log(error: error); producer.fail(error) }
            }
            
            self.add(delete)
        }
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}
