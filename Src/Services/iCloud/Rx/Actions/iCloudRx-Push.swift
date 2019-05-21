//
//  iCloudRx-Push.swift
//  KeyKey
//
//  Created by Loki on 5/13/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit
import RxSwift

func iCloudRxPush(records: [CKRecord], batchSize: Int, cloudDB: CKDatabase) -> Observable<[CKRecord]> {
    guard batchSize > 0     else { fatalError() }
    guard records.count > 0 else { return Observable<[CKRecord]>.empty() }
    
    return Observable.from(records.splitBy(batchSize))
        .flatMap { pushBlock(records: $0, cloudDB: cloudDB) }
}

fileprivate func pushBlock(records: [CKRecord], cloudDB: CKDatabase) -> Observable<[CKRecord]> {
    guard records.count > 0 else { return Observable<[CKRecord]>.empty() }
    
    return Observable<[CKRecord]>.create { observer in
        
        waitForCallback { STOP_WAITING in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            
            operation.modifyRecordsCompletionBlock = { records, _, error in
                if let error = error            { observer.onError(error) }
                if let records = records        { observer.onNext(records)    }
            }
            operation.completionBlock =            { observer.onCompleted(); STOP_WAITING() }
            
            cloudDB.add(operation)
        }
        
        return Disposables.create()
    }
}
