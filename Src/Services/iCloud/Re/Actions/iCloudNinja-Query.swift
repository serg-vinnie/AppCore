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

//private func performRecursive(cursor: CKQueryOperation.Cursor?, cloudDB :CKDatabase, batchSize: Int) -> Channel<CKRecord, CKQueryOperation.Cursor?> {
//    if let cursor = cursor {
//        AppCore.log(title: "iCloudNinja", msg: "performRecursive cursor")
//        return performRecursive(operation: CKQueryOperation(cursor: cursor), cloudDB: cloudDB, batchSize: batchSize)
//    } else {
//        AppCore.log(title: "iCloudNinja", msg: "performRecursive cursor final")
//        return channel(updates: [], success: nil)
//    }
//}



func performRecursive(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) -> Channel<CKRecord, Void> {
    AppCore.log(title: "iCloudNinja", msg: "performRecursive operation")
    
    let parentProducer = Producer<CKRecord,Void>()
    
    parentProducer
        .perform(operation: operation, cloudDB: cloudDB, batchSize: batchSize)
        .onSuccess() { [weak parentProducer] cursor in
            if let cursor = cursor {
                _ = parentProducer?.perform(operation: CKQueryOperation(cursor: cursor), cloudDB: cloudDB, batchSize: batchSize)
                //let p2 = Producer<CKRecord,CKQueryOperation.Cursor?>()
                //p2.perform(operation: CKQueryOperation(cursor: cursor), cloudDB: cloudDB, batchSize: batchSize)
                //p2.onUpdate() { parentProducer.update($0) }
                //p2.onFailure() { parentProducer.fail($0)}
            } else {
                parentProducer?.succeed(())
            }
    }
    
    return parentProducer
}

private extension Producer where Update == CKRecord, Success == Void {
    func perform(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) -> Producer<CKRecord,CKQueryOperation.Cursor?> {
        let p = Producer<CKRecord,CKQueryOperation.Cursor?>()
        p.perform(operation: operation, cloudDB: cloudDB, batchSize: batchSize)
        p.onUpdate() { self.update($0) }
        p.onFailure { self.fail($0) }
        
        return p
    }
}

private extension Producer where Update == CKRecord, Success == CKQueryOperation.Cursor? {
    func perform(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) {
        AppCore.log(title: "iCloudNinja", msg: "perform operation")
        
            operation.resultsLimit = batchSize
            operation.recordFetchedBlock = {
                log(msg: "did fetch \($0.recordID.recordName)");
                self.update($0) }
            operation.queryCompletionBlock = { cursor, error in
                if let error = error { self.fail(error) }
                self.succeed(cursor)
            }
            cloudDB.add(operation)
        
    }

}

//func perform(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) -> Channel<CKRecord, CKQueryOperation.Cursor?> {
//    AppCore.log(title: "iCloudNinja", msg: "perform operation")
//    return producer() { producer in
//        operation.resultsLimit = batchSize
//        operation.recordFetchedBlock = {
//            log(msg: "did fetch \($0.recordID.recordName)");
//            producer.update($0) }
//        operation.queryCompletionBlock = { cursor, error in
//            if let error = error { producer.fail(error) }
//            producer.succeed(cursor)
//        }
//        cloudDB.add(operation)
//    }
//}

//func perform(operation: CKQueryOperation, cloudDB: CKDatabase, batchSize: Int) -> Channel<CKRecord, CKQueryOperation.Cursor?> {
//    var records = [CKRecord]()
//
//    operation.resultsLimit = batchSize
//    operation.recordFetchedBlock = { records.append($0) }
//
//    switch futureFor(operation: operation, cloudDB: cloudDB).wait() {
//
//    case let.success(cursor):
//        return channel(updates: records, completion: .success(cursor))
//
//    case let .failure(error):
//        return channel(updates: records, completion: .failure(error))
//    }
//}
//
//func futureFor(operation: CKQueryOperation, cloudDB: CKDatabase) -> Future<CKQueryOperation.Cursor?> {
//    let promise = Promise<CKQueryOperation.Cursor?>()
//    operation.queryCompletionBlock = { cursor, error in
//        if let error = error {
//            promise.fail(error)
//        }
//        promise.succeed(cursor)
//    }
//
//    cloudDB.add(operation)
//    return promise
//}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error)
}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg)
}
