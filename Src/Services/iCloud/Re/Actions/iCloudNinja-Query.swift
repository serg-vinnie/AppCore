//
//  iCloudNinja-Query.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKDatabase {
    func perform(operation: CKQueryOperation, batchSize: Int) -> Channel<[CKRecord], Void> {
        log(msg: "perform operation")
        
        return Producer<[CKRecord],Void>()
            .iterate(operation: operation, transform: { CKQueryOperation(cursor: $0) }) { producer, operation in
                
                log(msg: "perform operation")
                producer.bind(operation: operation)
                
                operation.resultsLimit = batchSize
                self.add(operation)
        }
    }

}

private extension Producer where Update == CKRecord, Success == CKQueryOperation.Cursor? {
    func bind(operation: CKQueryOperation) {
        operation.recordFetchedBlock = {
            log(msg: "fetched \($0.recordType) \($0.recordID.recordName)")
            self.update($0)
        }
        operation.queryCompletionBlock = { cursor, error in
            
            if let error = error { log(error: error); self.fail(error) }
            self.succeed(cursor)
        }
    }
}

private extension Producer where Update == [CKRecord], Success == Void {

    @discardableResult
    func iterate(operation: CKQueryOperation, transform: @escaping (CKQueryOperation.Cursor)->(CKQueryOperation), block: @escaping (Producer<CKRecord,CKQueryOperation.Cursor?>, CKQueryOperation)->()) -> Producer<[CKRecord],Void> {
        var records = [CKRecord]()
        records.reserveCapacity(400)
        
        let p = Producer<CKRecord,CKQueryOperation.Cursor?>()
        block(p, operation)
        p.onUpdate() { records.append($0) } 
        p.onFailure { self.fail($0) }
     
        p.onSuccess() { cursor in
            
            self.update(records)
            if let cursor = cursor {
                log(msg: "Operation step succeded. Going to perform next step")
                self.iterate(operation: transform(cursor), transform: transform, block: block)
            } else {
                log(msg: "Operation completed")
                self.succeed(())
            }
        }.onFailure() { error in
            log(msg: "operation step failed")
            log(error: error)
        }
        
        return self
    }
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}
