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
    func perform(operation: CKQueryOperation, batchSize: Int, executor: Executor = .iCloud) -> Channel<[CKRecord], Void> {
        log(msg: "perform operation")
        
        return Producer<[CKRecord],Void>()
            .iterate(operation: operation, executor: executor) { [weak self] producer, operation in
                
                log(msg: "perform operation")
                producer.bind(operation: operation, executor: executor)
                
                operation.resultsLimit = batchSize
                self?.add(operation)
        }
    }

}

private extension Producer where Update == CKRecord, Success == CKQueryOperation.Cursor? {
    func bind(operation: CKQueryOperation, executor: Executor) {
        operation.recordFetchedBlock = { [weak self] in
            log(msg: "fetched \($0.recordType) \($0.recordID.recordName)")
            self?.update($0, from: executor)
        }
        operation.queryCompletionBlock = { [weak self] cursor, error in
            
            if let error = error { log(error: error); self?.fail(error, from: executor) }
            self?.succeed(cursor, from: executor)
        }
    }
}

private extension Producer where Update == [CKRecord], Success == Void {

    @discardableResult
    func iterate(operation: CKQueryOperation, executor: Executor, block: @escaping (Producer<CKRecord,CKQueryOperation.Cursor?>, CKQueryOperation)->()) -> Producer<[CKRecord],Void> {
        var records = [CKRecord]()
        records.reserveCapacity(400)
        
        let producer = Producer<CKRecord,CKQueryOperation.Cursor?>()
        block(producer, operation)
        
        producer
            .onUpdate(executor: executor) { records.append($0) }
            .onSuccess(executor: executor) { [weak self] cursor in
                
                self?.update(records, from: executor)
                if let cursor = cursor {
                    log(msg: "Operation step succeded. Going to perform next step")
                    self?.iterate(operation: CKQueryOperation(cursor: cursor), executor: executor, block: block)
                } else {
                    log(msg: "Operation completed")
                    self?.succeed(from: executor)
                }
            }.onFailure(executor: executor) { [weak self] error in
                log(msg: "operation step failed")
                log(error: error)
                self?.fail(error, from: executor)
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
