//
//  iCloudRxFetch.swift
//  KeyKey
//
//  Created by Loki on 5/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit
import RxSwift

func iCloudRxFetch(ids: [CKRecord.ID], cloudDB: CKDatabase, batchSize: Int) -> Observable<CKRecord> {
    guard batchSize > 0 else { fatalError() }
    guard ids.count > 0 else { return Observable<CKRecord>.empty() }
    
    return Observable.from(ids.splitBy(batchSize))
        .flatMap { fetchBlock(ids: $0, cloudDB: cloudDB) }
}

private func fetchBlock(ids: [CKRecord.ID], cloudDB: CKDatabase) -> Observable<CKRecord> {
    guard ids.count > 0 else { return Observable<CKRecord>.empty() }
    
    return Observable<CKRecord>.create { observer in
        
        waitForCallback { STOP_WAITING in
            let fetch = CKFetchRecordsOperation(recordIDs: ids)
            
            fetch.perRecordCompletionBlock = { record, recordID, error in
                if let error = error            { observer.onError(error) }
                if let record = record          { observer.onNext(record) }
            }
            
            fetch.completionBlock = { observer.onCompleted(); STOP_WAITING() }
            cloudDB.add(fetch)
        }
        
        return Disposables.create()
    }
    
}
