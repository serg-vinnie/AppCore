//
//  iCloudFetcher.swift
//  KeyKey
//
//  Created by Loki on 3/27/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//


import CloudKit
import RxSwift

public class iCloudFetcherRx {
    
    public let serialScheduler = SerialDispatchQueueScheduler.init(internalSerialQueueName: "com.keykey.iCloudFetcherRx")
    
    private(set) var cloudDB: CKDatabase
    private(set) var maxNumberOfItems = 2

    private var _eventsPerBlock  = PublishSubject<[CKRecord.ID : CKRecord]>()
    private var _eventsPerRecord = PublishSubject<CKRecord>()
    
    public var eventsPerBlock  : Observable<[CKRecord.ID : CKRecord]> { return _eventsPerBlock }
    public var eventsPerRecord : Observable<CKRecord>                { return _eventsPerRecord }
    
    private let bag = DisposeBag()

    public init(cloudDB: CKDatabase, ids: [CKRecord.ID]){
        self.cloudDB = cloudDB
        //fetch(ids: ids)
    }
    
    deinit {
        print("iCloudFetcher deinit")
        self._eventsPerRecord.onCompleted()
        self._eventsPerBlock.onCompleted()
    }
    
    private func fetch(ids: [CKRecord.ID]) {
        let subArrays = ids.splitBy(maxNumberOfItems)
        let operationOrder = OperationOrder()
        
        for subRecordsIDs in subArrays {
            let fetch = CKFetchRecordsOperation(recordIDs: subRecordsIDs)
            
            fetch.perRecordCompletionBlock = { record, recordID, error in
                if let error = error            { self._eventsPerRecord.onError(error) }
                if let record = record          { self._eventsPerRecord.onNext(record) }
            }
            
            fetch.fetchRecordsCompletionBlock = { recordsMap, error in
                if let error = error            { self._eventsPerBlock.onError(error) }
                if let recordsMap = recordsMap  { self._eventsPerBlock.onNext(recordsMap) }
            }
            
            operationOrder.addAsDependentOfPrevious(fetch)
            cloudDB.add(fetch)
        }
    }
    
    public func fetch2(ids: [CKRecord.ID]) -> Observable<CKRecord> {
        let subArrays = ids.splitBy(maxNumberOfItems)
        
        return Observable<CKRecord>.create { [weak self] subscribe in

            for ids in subArrays {
                self?.fetchBlock(ids: ids)
                    .subscribeOn(self!.serialScheduler).observeOn(MainScheduler.instance)
                    .subscribe(onNext:  { subscribe.onNext($0) }, onError:  { subscribe.onError($0) } )
                    .disposed(by: self!.bag)
            }
            
            self?.fetchBlock(ids: [])
                .subscribeOn(self!.serialScheduler).observeOn(MainScheduler.instance)
                .subscribe(onCompleted: { subscribe.onCompleted() } ).disposed(by: self!.bag)
            
            return Disposables.create()
        }
    }
    
    private func fetchBlock(ids: [CKRecord.ID]) -> Observable<CKRecord> {
        return Observable<CKRecord>.create { [weak self] subscribe in
            guard (self != nil) || (ids.count > 0) else {
                subscribe.onCompleted()
                return Disposables.create()
            }
            
            let DISPATCH_GROUP = DispatchGroup()
            DISPATCH_GROUP.enter()
            
            let fetch = CKFetchRecordsOperation(recordIDs: ids)
            
            fetch.perRecordCompletionBlock = { record, recordID, error in
                if let error = error            { subscribe.onError(error) }
                if let record = record          { subscribe.onNext(record) }
            }
            
            fetch.completionBlock = { subscribe.onCompleted(); DISPATCH_GROUP.leave() }
            self!.cloudDB.add(fetch)

            DISPATCH_GROUP.wait()
            
            return Disposables.create()
        }
        
    }
}
