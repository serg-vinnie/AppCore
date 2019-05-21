//
//  iCloudRx-Query.swift
//  KeyKey
//
//  Created by Loki on 5/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit
import RxSwift

func iCloudRxQuery(_ query: CKQuery, cloudDB: CKDatabase, batchSize: Int) -> Observable<[CKRecord]> {
    return iterate(operation: CKQueryOperation(query: query), batchSize: batchSize)
        .observeOn(MainScheduler.asyncInstance)
        .flatMap { perform(operation: $0, cloudDB: cloudDB)}
}

private func iterate(operation: CKQueryOperation, batchSize: Int) -> Observable<CKQueryOperation> {
    return Observable<CKQueryOperation>.create { observer in
        
        operation.resultsLimit = batchSize
        operation.queryCompletionBlock = getQueryComplitionBlock(observer: observer, batchSize: batchSize)
        
        observer.onNext(operation)
        
        return Disposables.create()
    }
}

private func perform(operation: CKQueryOperation, cloudDB: CKDatabase) -> Observable<[CKRecord]> {
    return Observable<[CKRecord]>.create { observer in
        
        var records = [CKRecord]()
        
        waitForCallback { STOP_WAITING in
            operation.recordFetchedBlock = { records.append($0) }
            operation.completionBlock = STOP_WAITING
            
            cloudDB.add(operation)
        }
        if records.count > 0 {
            observer.onNext(records)
        }
        observer.onCompleted()
        return Disposables.create()
    }
}

private func getQueryComplitionBlock(observer: AnyObserver<CKQueryOperation>, batchSize: Int) -> ((CKQueryOperation.Cursor?, Error?) -> ()) {
    let block = { (cursor: CKQueryOperation.Cursor?, error: Error?) in
        if let cursor = cursor {
            let nextOperation = CKQueryOperation(cursor: cursor)
            
            nextOperation.resultsLimit = batchSize
            nextOperation.queryCompletionBlock = getQueryComplitionBlock(observer: observer, batchSize: batchSize)
            
            observer.onNext(nextOperation)
        } else {
            observer.onCompleted()
        }
        if let error = error {
            observer.onError(error)
        }
    }
    
    return block
}

