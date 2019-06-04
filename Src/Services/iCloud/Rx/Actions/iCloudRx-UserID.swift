//
//  iCloudRx-UserID.swift
//  Focusito
//
//  Created by Loki on 8/2/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import CloudKit
import RxSwift

func iCloudRxFetchUserRecordID(container: CKContainer) -> Observable<CKRecord.ID> {
    return Observable<CKRecord.ID>.create { observer in
        defer { observer.onCompleted() }
        
        waitForCallback { STOP_WAITING in
            container.fetchUserRecordID() {
                
                if let recordID = $0 { observer.onNext(recordID) }
                if let error    = $1 { observer.onError(error) }
                
                STOP_WAITING()
            }
        }
        
        return Disposables.create()
    }
}

