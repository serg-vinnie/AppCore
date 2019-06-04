//
//  iCloudRx-Delete.swift
//  KeyKey
//
//  Created by Loki on 5/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit
import RxSwift

func iCloudRxDelete(IDs: [CKRecord.ID], batchSize: Int, cloudDB: CKDatabase) -> Observable<[CKRecord.ID]> {
    guard batchSize > 0     else { fatalError() }
    guard IDs.count > 0 else { return Observable<[CKRecord.ID]>.empty() }
    
    return Observable.from(IDs.splitBy(batchSize))
        .flatMap { deleteBlock(IDs: $0, cloudDB: cloudDB) }

}

fileprivate func deleteBlock(IDs: [CKRecord.ID], cloudDB: CKDatabase) -> Observable<[CKRecord.ID]> {
    return Observable<[CKRecord.ID]>.create { observer in
        
        waitForCallback { STOP_WAITING in
            let delete = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
            
            delete.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
                if let error = error            { observer.onError(error) }
                if let IDs = deletedRecordIDs   { observer.onNext(IDs)    }
            }
            delete.completionBlock =            { observer.onCompleted(); STOP_WAITING() }
            
            cloudDB.add(delete)
        }
        
        return Disposables.create()
    }
}
