//
//  ReCloud-Push.swift
//  SwiftCore
//
//  Created by Loki on 1/10/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKDatabase {
    func push(records: [CKRecord]) -> Channel<[CKRecord],Void> {
        return producer() { producer in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.modifyRecordsCompletionBlock = { records, _, error in
                if let error = error            { log(error: error); producer.fail(error) }
                if let records = records        { producer.update(records); producer.succeed(()) }
            }
            self.add(operation)
        }
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error, thread: true)
}
