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
    func delete(IDs: [CKRecord.ID]) -> Future<[CKRecord.ID]> {
        
        log(msg: "going to delete \(IDs.count) records")
        
        return promise() { [weak self] promise in
            let delete =  CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
            
            delete.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
            
                if let IDs = deletedRecordIDs   { log(msg: "\(IDs.count) deleted"); promise.succeed(IDs) }
                if let error = error            { log(error: error);                promise.fail(error) }
            }
            
            self?.add(delete)
        }
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}
