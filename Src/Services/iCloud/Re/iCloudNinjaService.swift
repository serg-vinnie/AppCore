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
    //public let internalQueue : DispatchQueue
    public var executor: Executor { return Executor.default }
    public let releasePool = ReleasePool()
    
    public let container  : CKContainer
    public let cloudDB    : CKDatabase
    
    public var batchSize  = 300
    
    public init(container: CKContainer, cloudDB: CKDatabase, queueId: String) {
        //self.internalQueue = DispatchQueue(label: queueId)
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
    
    public func push(records: Channel<[CKRecord],Void>) -> Channel<[CKRecord], Void> {
        return records
            .flatMap(context: self) { $0.split(items: $1) }
            .flatMap(context: self) { me, recs in me.cloudDB.push(records: recs) }
    }
    
    public func push(records: [CKRecord]) -> Channel<[CKRecord], Void> {
        return cloudDB.push(records: records)
    }

    private func split<T>(items: [T]) -> Channel<[T],Void> {
        return channel(updates: items.splitBy(batchSize), success: ())
    }
    
    public func fetch(IDs: [CKRecord.ID]) -> Channel<[CKRecord.ID:CKRecord], Void> {
        return cloudDB.fetch(IDs: IDs)
            .asChannel()
    }
    
    public func fetchChangeWith(token: CKServerChangeToken?) -> Channel<CKQueryNotification, CKServerChangeToken> {
        return container.fetch(token: token)
    }
    
    public func fetch(query: CKQuery) -> Channel<[CKRecord], Void> {
        return cloudDB.perform(operation: CKQueryOperation(query: query), batchSize: batchSize)
    }
    
    public func fetchRecordsOf(type: String, predicate: NSPredicate? = nil) -> Channel<[CKRecord], Void> {
        let queryAll = CKQuery(recordType: type, predicate: predicate ?? NSPredicate(value: true))
        return fetch(query: queryAll)
    }
    
    public func delete(IDs: Channel<[CKRecord.ID], Void>, skipErrors: Bool = false) -> Channel<[CKRecord.ID], Void> {
        return IDs
            .flatMap(context: self) { $0.split(items: $1) }
            .flatMap(context: self) { me, ids in me.cloudDB.delete(IDs: ids) }
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
    func asChannel(debugID: String? = nil) -> Channel<Success,Void> {
        return producer() { [weak self] producer in
            producer.debugID = debugID
            self?.onFailure { producer.fail($0) }
            self?.onSuccess {
                producer.update($0);
                sleep(1)
                producer.succeed() }
        }
    }
}
