//
//  iCloudNinja-Query.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

// this method should be called from background thread
//func iCloudNinjaFetch(ctx: AsyncNinja.ExecutionContext, query: CKQuery, cloudDB: CKDatabase, batchSize: Int) -> Channel<[CKRecord],Void> {
//    return channel(context: ctx) { _, update in
//        var operation : CKQueryOperation? = CKQueryOperation(query: query)
//
//        repeat {
//            guard let next = operation else { return }
//
//            let(records, cursor) = perform(operation: next, cloudDB: cloudDB, batchSize: batchSize).waitForAll()
//
//            if records.count > 0 {
//                update(records)
//            }
//
//            switch cursor {
//            case let .success(cursor):
//                operation = cursor != nil ? CKQueryOperation(cursor: cursor!) : nil
//
//            case let .failure(error):
//                throw error
//            }
//
//        } while true
//    }
//}

func perform(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) -> Channel<CKRecord, CKQueryOperation.Cursor?> {
    var records = [CKRecord]()
    
    operation.resultsLimit = batchSize
    operation.recordFetchedBlock = { records.append($0) }
    
    switch futureFor(operation: operation, cloudDB: cloudDB).wait() {
        
    case let.success(cursor):
        return channel(updates: records, completion: .success(cursor))
        
    case let .failure(error):
        return channel(updates: records, completion: .failure(error))
    }
}

func futureFor(operation: CKQueryOperation, cloudDB: CKDatabase) -> Future<CKQueryOperation.Cursor?> {
    let promise = Promise<CKQueryOperation.Cursor?>()
    operation.queryCompletionBlock = { cursor, error in
        if let error = error {
            promise.fail(error)
        }
        promise.succeed(cursor)
    }
    
    cloudDB.add(operation)
    return promise
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinjaFetch(query:", error: error)
}
