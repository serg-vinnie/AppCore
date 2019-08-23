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

fileprivate let cloudExecutor = Executor(queue: DispatchQueue(label: "iCloudQueue"))

public class iCloundNinjaPrivate : iCloudNinjaService {
    init() {
        super.init(container: CKContainer.default(), cloudDB: privateDB, executor: cloudExecutor)
    }
}

public class iCloundNinjaPublic : iCloudNinjaService {
    init() {
        super.init(container: CKContainer.default(), cloudDB: publicDB, executor: cloudExecutor)
    }
}



public class iCloudNinjaService : ExecutionContext, ReleasePoolOwner {
    public let executor: Executor
    public let releasePool = ReleasePool()
    
    public let container  : CKContainer
    public let cloudDB    : CKDatabase
    
    public var batchSize  = 300
    
    public init(container: CKContainer, cloudDB: CKDatabase, executor: Executor) {
        self.executor = executor
        self.container  = container
        self.cloudDB    = cloudDB
    }
    
    public func waitForAuth(retryAfterSeconds: UInt32 = 30) -> Future<Void> {
        return future(context: self, executor: .default) { ctx in
            while ctx.status() != .available {
                sleep(retryAfterSeconds)
            }
        }
    }
    
    public func status() -> CKAccountStatus {
        let status = container.status().wait()
        return status.success ?? .couldNotDetermine
    }
    
    public func push(records: Channel<[CKRecord],Void>) -> Channel<[CKRecord], Void> {
        return records
          .flatMap(context: self, executor: Executor.default) { $0.split(items: $1) }
          .flatMap(context: self, executor: Executor.default) { $0.push(records: $1) }
    }
    
    public func push(records: [CKRecord]) -> Channel<[CKRecord], Void> {
        return cloudDB.push(records: records)
            .asChannel(executor: executor)
    }

    private func split<T>(items: [T]) -> Channel<[T],Void> {
        return producer(executor: .default) { me, producer in
            for batch in items.splitBy(me.batchSize) {
                producer.update(batch)
            }
            AppCore.sleep(for: 0.5)
            producer.succeed(())
        }
    }
    
    public func fetch(IDs: [CKRecord.ID]) -> Channel<[CKRecord.ID:CKRecord], Void> {
        return split(items: IDs)
            .flatMap(context: self, executor: .primary) { me, IDs in
                return me.cloudDB
                    .fetch(IDs: IDs)
                    .asChannel(executor: me.executor)
        }
    }
    
    public func fetchChangeWith(token: CKServerChangeToken?) -> Channel<CKQueryNotification, CKServerChangeToken> {
        return container.fetch(token: token, executor: executor)
    }
    
    public func fetch(query: CKQuery) -> Channel<[CKRecord], Void> {
        return cloudDB.perform(operation: CKQueryOperation(query: query), batchSize: batchSize, executor: executor)
    }
    
    public func fetchRecordsOf(type: String, predicate: NSPredicate? = nil) -> Channel<[CKRecord], Void> {
        let queryAll = CKQuery(recordType: type, predicate: predicate ?? NSPredicate(value: true))
        return fetch(query: queryAll)
    }
    
    public func delete(IDs: Channel<[CKRecord.ID], Void>, skipErrors: Bool = false) -> Channel<[CKRecord.ID], Void> {
        return IDs
            .flatMap(context: self, executor: Executor.default) { $0.split(items: $1) }
            .flatMap(context: self, executor: Executor.default) { me, ids in me.cloudDB.delete(IDs: ids).asChannel(executor: me.executor) }
    }
    
    public func deleteRecordsOf(type: String, skipErrors: Bool = false) -> Channel<[CKRecord.ID], Void> {
        let ids = fetchRecordsOf(type: type).map { $0.map { $0.recordID } }
        return delete(IDs: ids, skipErrors: skipErrors)
    }
    
    public func subscribe(to subscription: CKSubscription) -> Future<CKSubscription> {
        return cloudDB.subscribe(subscription)
    }
    
    public func fetchAllSubscriptions() -> Future<[CKSubscription]> {
        return cloudDB.fetchAllSubscriptions()
    }
    
    public func userRecordID() -> Future<CKRecord.ID> {
        return container.userRecordID()
    }
}


fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}

public extension Future {
    func asChannel(executor: Executor) -> Channel<Success,Void> {
        return producer(executor: executor) { producer in
            self.onFailure { producer.fail($0, from: executor) }
            self.onSuccess {
                producer.update($0, from: executor);
                AppCore.sleep(for: 0.5)
                producer.succeed(from: executor) }
        }
    }
}
