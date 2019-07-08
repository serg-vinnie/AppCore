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

    private func split<T>(items: [T]) -> Channel<[T],Void> {
        return channel(updates: items.splitBy(batchSize), success: ())
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
    
    public func fetchWithChangeToken() -> Channel<CKQueryNotification, CKServerChangeToken> {
        return container.fetch(token: serverChangeToken)
            .onSuccess(context: self) {me, token in me.serverChangeToken = token }
    }
    
    public func fetch(query: CKQuery) -> Channel<[CKRecord], Void> {
        return cloudDB.perform(operation: CKQueryOperation(query: query), batchSize: batchSize)
            .mapSuccess { _ in () }
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
}


fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}


private let changeTokenKey = "iCloudNinja.changeToken"

public extension iCloudNinjaService {
    var serverChangeToken: CKServerChangeToken? {
        get {
            guard let data = UserDefaults.standard.value(forKey: changeTokenKey) as? Data else {
                return nil
            }
            
            guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else {
                return nil
            }
            
            return token
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                UserDefaults.standard.set(data, forKey: changeTokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: changeTokenKey)
            }
        }
    }
}
