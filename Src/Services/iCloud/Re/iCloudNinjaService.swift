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

public extension Executor {
    static let iCloud           = Executor(queue: DispatchQueue(label: "iCloudQueue"))
    static let iCloudFlatMap    = Executor(queue: DispatchQueue(label: "iCloudFlatMap"))
}

public class iCloundNinjaPrivate : iCloudNinjaService {
    init() {
        super.init(container: CKContainer.default(), cloudDB: privateDB, executor: .iCloud)
    }
}

public class iCloundNinjaPublic : iCloudNinjaService {
    init() {
        super.init(container: CKContainer.default(), cloudDB: publicDB, executor: .iCloud)
    }
}



public class iCloudNinjaService : ExecutionContext, ReleasePoolOwner {
    public let executor: Executor
    public let releasePool = ReleasePool()
    
    public let container  : CKContainer
    public let cloudDB    : CKDatabase
    
    public var batchSize  = 100
    
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
          //.flatMap(context: self, executor: .iCloudFlatMap) { $0.split(items: $1) }
          .flatMap(context: self, executor: .iCloudFlatMap) { $0.cloudDB.push(records: $1).asChannel(executor: .iCloud) }
    }
    
    public func push(records: [CKRecord]) -> Channel<[CKRecord], Void> {
        return split(items: records)
            .flatMap(context: self, executor: .iCloudFlatMap) { me, records in
                return me.cloudDB
                    .push(records: records)
                    .asChannel(executor: .iCloud)
        }
    }
    
    public func fetch(IDs: [CKRecord.ID]) -> Channel<[CKRecord.ID:CKRecord], Void> {
        return split(items: IDs)
            .flatMap(context: self, executor: .iCloudFlatMap) { me, IDs in
                return me.cloudDB
                    .fetch(IDs: IDs)
                    .asChannel()
        }
    }
    
    public func fetchChangeWith(token: CKServerChangeToken?) -> Channel<CKQueryNotification, CKServerChangeToken> {
        return container.fetch(token: token, executor: executor)
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
            //.flatMap(context: self, executor: .iCloudFlatMap) { $0.split(items: $1) }
            .flatMap(context: self, executor: .iCloudFlatMap) { me, ids in
                me.cloudDB.delete(IDs: ids).asChannel(executor: .iCloud)
        }
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

extension iCloudNinjaService {
    func split<T>(items: [T]) -> Channel<[T],Void> {
        return producer(executor: .iCloud, bufferSize: 0) { me, producer in
            for batch in items.splitBy(me.batchSize) {
                producer.update(batch)
            }
            producer.succeed(())
        }
    }
}


fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}

public extension Future {
    func asChannel(executor: Executor = .iCloud) -> Channel<Success,Void> {
        return producer(executor: executor) { producer in
            self.onComplete(executor: executor) { fallible in
                switch fallible {
                case .success(let succ):
                    producer.update(succ, from: executor)
                    producer.succeed(from: executor)
                case .failure(let err):
                    producer.fail(err, from: executor) }
                
            }
        }
    }
    
//    func asChannel(executor: Executor = .immediate) -> Channel<Success,Void> {
//        let producer = Producer<Success,Void>(bufferSize: 0)
//        self.onComplete(executor: executor) { fallible in
//            switch fallible {
//            case .success(let succ):
//                producer.update(succ, from: executor)
//                AppCore.sleep(for: 0.5)
//                producer.succeed(from: executor)
//            case .failure(let err):
//                producer.fail(err, from: executor) }
//
//        }
//        return producer
//    }
}

