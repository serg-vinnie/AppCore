//
//  iCloudNinja-Query.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

func perform(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) -> Channel<CKRecord, Void> {
    AppCore.log(title: "iCloudNinja", msg: "perform operation")
    
    return Producer<CKRecord,Void>()
        .iterate(operation: operation, transform: { CKQueryOperation(cursor: $0) }) { producer, operation in
            
            AppCore.log(title: "iCloudNinja", msg: "perform operation")
            producer.bind(operation: operation)
            
            operation.resultsLimit = batchSize
            cloudDB.add(operation)
    }
}

private extension Producer where Update == CKRecord, Success == CKQueryOperation.Cursor? {
    func bind(operation: CKQueryOperation) {
        operation.recordFetchedBlock = {
            self.update($0) }
        operation.queryCompletionBlock = { cursor, error in
            if let error = error { self.fail(error) }
            self.succeed(cursor)
        }
    }
}

private extension Producer where Update == CKRecord, Success == Void {

    @discardableResult
    func iterate(operation: CKQueryOperation, transform: @escaping (CKQueryOperation.Cursor)->(CKQueryOperation), block: @escaping (Producer<CKRecord,CKQueryOperation.Cursor?>, CKQueryOperation)->()) -> Producer<CKRecord,Void> {
        let p = Producer<CKRecord,CKQueryOperation.Cursor?>()
        block(p, operation)
        p.onUpdate() { self.update($0) }
        p.onFailure { self.fail($0) }
     
        p.onSuccess() { cursor in
            if let cursor = cursor {
                self.iterate(operation: transform(cursor), transform: transform, block: block)
            } else {
                self.succeed(())
            }
        }
        
        return self
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg)
}
