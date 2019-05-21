//
//  iCloudRxService.swift
//  KeyKey
//
//  Created by Loki on 5/9/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import Foundation
import CloudKit
import RxSwift

public class iCloudRxService {
    public var mainQueue        : SchedulerType                 // serial queue by default
    public var batchSize        = 20  { didSet { assert(batchSize != 0) } } // CKQueryOperation.maximumResults
    public var observeOn        = MainScheduler.instance
    
    public let container  : CKContainer
    public let cloudDB    : CKDatabase
    
    public let authorized : Observable<Void>
    
    public init(container: CKContainer, cloudDB: CKDatabase, queueId: String) {
        self.container  = container
        self.cloudDB    = cloudDB
        
        mainQueue = SerialDispatchQueueScheduler.init(internalSerialQueueName: queueId)
        authorized = iCloudRxWaitForAuth(container: container, retryAfterSeconds: 30)
    }
    
    public func waitForAuth(scheduler : SerialDispatchQueueScheduler = MainScheduler.instance) -> Observable<Void> {
        return iCloudRxWaitForAuth(container: container)
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func checkAccountStatus() -> Observable<CKAccountStatus> {
        return iCloudRxCheckAccountStatus(container: container)
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func listenStatus() -> Observable<CKAccountStatus> {
        return iCloudRxListenStatus(container: container)
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func push(records: [CKRecord]) -> Observable<[CKRecord]> {
        return authorized.flatMap { iCloudRxPush(records: records, batchSize: self.batchSize, cloudDB: self.cloudDB) }
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func push(records: Observable<[CKRecord]>) -> Observable<[CKRecord]> {
        return authorized.flatMap { records }
            .subscribeOn(mainQueue)
            .observeOn(mainQueue)
            .flatMap { iCloudRxPush(records: $0, batchSize: self.batchSize, cloudDB: self.cloudDB) }
            .observeOn(observeOn)
    }
    
    public func query(_ query: CKQuery ) -> Observable<[CKRecord]> {
        return authorized.flatMap { iCloudRxQuery(query, cloudDB: self.cloudDB, batchSize: self.batchSize) }
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func delete(IDs: [CKRecord.ID]) -> Observable<[CKRecord.ID]> {
        return authorized.flatMap { iCloudRxDelete(IDs: IDs, batchSize: self.batchSize, cloudDB: self.cloudDB) }
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func delete(IDs: Observable<[CKRecord.ID]>) -> Observable<[CKRecord.ID]> {
        return authorized.flatMap { IDs }
            .subscribeOn(mainQueue)
            .observeOn(mainQueue)
            .flatMap { iCloudRxDelete(IDs: $0, batchSize: self.batchSize, cloudDB: self.cloudDB) }
            .observeOn(observeOn)
    }
    
    public func fetch(ids: [CKRecord.ID]) -> Observable<CKRecord> {
        return authorized.flatMap { iCloudRxFetch(ids: ids, cloudDB: self.cloudDB, batchSize: self.batchSize) }
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
    
    public func fetchCurrentUserID() -> Observable<CKRecord.ID>  {
        return authorized.flatMap { iCloudRxFetchUserRecordID(container: self.container) }
            .subscribeOn(mainQueue)
            .observeOn(observeOn)
    }
}

public extension iCloudRxService {
    public func queryRecordsOf(type: String, predicate: NSPredicate? = nil) -> Observable<[CKRecord]> {
        let queryAll = CKQuery(recordType: type, predicate: predicate ?? NSPredicate(value: true))
        return query(queryAll)
    }
    
    public func delete(records: Observable<[CKRecord]>) -> Observable<[CKRecord.ID]> {
        return delete(IDs: records.map { $0.map { $0.recordID } })
    }
    
    public func deleteBy(query: CKQuery) -> Observable<[CKRecord.ID]>  {
        let queryResult = self.query(query)
            .map { $0.map { $0.recordID } }
        
        return delete(IDs: queryResult)
    }
    
    public func deleteRecordsOf(type: String) -> Observable<[CKRecord.ID]> {
        return delete(records: queryRecordsOf(type: type))
    }
}
