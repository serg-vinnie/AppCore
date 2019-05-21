//
//  iCloudNinjaService.swift
//  SwiftCore
//
//  Created by Loki on 1/10/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import AsyncNinja
import CloudKit

fileprivate let publicDB  = CKContainer.default().publicCloudDatabase
fileprivate let privateDB = CKContainer.default().privateCloudDatabase
fileprivate let cloudQueueID = "iCloudThread"

public class iCloundNinjaPrivate : iCloudNinjaService {
    init() {
        super.init(container: CKContainer.default(), cloudDB: privateDB, queueId: cloudQueueID)
    }
}

public class iCloundNinjaPublic : iCloudNinjaService {
    init() {
        super.init(container: CKContainer.default(), cloudDB: publicDB, queueId: cloudQueueID)
    }
}



public class iCloudNinjaService : ExecutionContext, ReleasePoolOwner {
    public let internalQueue : DispatchQueue
    public var executor: Executor { return Executor.init(queue: internalQueue) }
    public let releasePool = ReleasePool()
    
    public let container  : CKContainer
    public let cloudDB    : CKDatabase
    
    public var batchSize  = 300
    
    public init(container: CKContainer, cloudDB: CKDatabase, queueId: String) {
        self.internalQueue = DispatchQueue(label: queueId)
        self.container  = container
        self.cloudDB    = cloudDB
    }
    
    public func waitForAuth(retryAfterSeconds: UInt32 = 30) -> Future<Void> {
        return future(context: self) { ctx in
            while ctx.status() != .available {
                sleep(retryAfterSeconds)
            }
        }
    }
    
    public func status() -> CKAccountStatus {
        let status = iCloudNinjaAccountStatus(container: container).wait()
        return status.success ?? .couldNotDetermine
    }
    
    public func push(records: [CKRecord], skipErrors: Bool = false) -> Channel<[CKRecord], Void> {
        return channel(context: self) { ctx, update in
            for batch in records.splitBy(ctx.batchSize) {
                
                log(msg: "going to push \(batch.count) records")
                
                switch iCloudNinjaPush(records: batch, cloudDB: ctx.cloudDB).wait() {
                    
                case let .success(pushedRecords):
                    update(pushedRecords)
                    
                case let .failure(error):
                    if !skipErrors {
                        throw error
                    }
                }
                
            }
        }
    }
    
    public func fetch(IDs: [CKRecord.ID]) -> Channel<[CKRecord], Void> {
        return channel(context: self) { ctx, update in
            for batch in IDs.splitBy(ctx.batchSize) {
                log(msg: "going to push \(batch.count) records")
                
                switch iCloudNinjaFetch(ids: batch, cloudDB: ctx.cloudDB).wait() {
                    
                case let .success(fetchedRecords):
                    let records = fetchedRecords.map { $0.value }
                    update(records)
                case let .failure(error):
                    throw error
                }
            }
        }
    }
    
    public func fetch(query: CKQuery) -> Channel<[CKRecord], Void> {
        return channel(context: self) { ctx, update in
            var operation : CKQueryOperation? = CKQueryOperation(query: query)
            
            repeat {
                guard let next = operation else { return }
                
                let(records, cursor) = perform(operation: next, cloudDB: ctx.cloudDB, batchSize: ctx.batchSize).waitForAll()
                
                if records.count > 0 {
                    update(records)
                    AppCore.log(title: "iCloudNinja", msg: "fetched \(records.count) records", thread: true)
                }
                
                switch cursor {
                case let .success(cursor):
                    operation = cursor != nil ? CKQueryOperation(cursor: cursor!) : nil
                    
                case let .failure(error):
                    throw error
                }
                
            } while true
        }
    }
    
    public func fetchRecordsOf(type: String, predicate: NSPredicate? = nil) -> Channel<[CKRecord], Void> {
        let queryAll = CKQuery(recordType: type, predicate: predicate ?? NSPredicate(value: true))
        return fetch(query: queryAll)
    }
    
    public func delete(IDs: [CKRecord.ID], skipErrors: Bool = false) -> Channel<[CKRecord.ID], Void> {
        return channel(context: self) { ctx, update in
            for batch in IDs.splitBy(ctx.batchSize) {
                log(msg: "going to delete \(batch.count) records")
                
                switch iCloudNinjaDelete(IDs: batch, batchSize: ctx.batchSize, cloudDB: ctx.cloudDB).wait() {
                    
                case let .success(deletedRecords):
                    update(deletedRecords)
                    
                case let .failure(error):
                    if !skipErrors {
                        throw error
                    }
                }
            }
        }
    }
    
    public func delete(IDs: Channel<[CKRecord.ID], Void>, skipErrors: Bool = false) -> Channel<[CKRecord.ID], Void> {
        return IDs
            .flatMap(context: self) { ctx, ids in ctx.delete(IDs: ids, skipErrors: skipErrors)}
    }
    
    public func deleteRecordsOf(type: String, skipErrors: Bool = false) -> Channel<[CKRecord.ID], Void> {
        let ids = fetchRecordsOf(type: type).map { $0.map { $0.recordID } }
        return delete(IDs: ids, skipErrors: skipErrors)
    }
}


fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}

