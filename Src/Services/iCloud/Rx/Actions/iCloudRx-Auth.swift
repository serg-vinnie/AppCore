//
//  iCloudAuthRx.swift
//  KeyKey
//
//  Created by Loki on 5/9/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit
import RxSwift

func iCloudRxWaitForAuth(container: CKContainer, retryAfterSeconds: UInt32 = 30) -> Observable<Void> {
    return Observable<Void>.create { observer in
        
        while CKAccountStatus.available != checkAccountStatus(container: container, onError: { observer.onError($0)} ) {
            print("iCloudRx: failed to auth. Retry in \(retryAfterSeconds) seconds...")
            sleep(retryAfterSeconds)
        }
        
        observer.onNext(())
        observer.onCompleted()
        
        return Disposables.create()
    }
}


func iCloudRxCheckAccountStatus(container: CKContainer) -> Observable<CKAccountStatus> {
    return Observable<CKAccountStatus>.create { observer in
        
        let status = checkAccountStatus(container: container, onError: { observer.onError($0)} )
        
        observer.onNext(status)
        observer.onCompleted()
        
        return Disposables.create()
    }
}

func iCloudRxListenStatus(container: CKContainer, retryAfterSeconds: UInt32 = 10) -> Observable<CKAccountStatus> {
    return Observable<CKAccountStatus>.create { observer in
        
        var status = CKAccountStatus.couldNotDetermine
        
        repeat {
            status = checkAccountStatus(container: container, onError: { observer.onError($0)} )
            observer.onNext(status)
            if status != .available {
                print("iCloudRx: failed to auth. Retry in \(retryAfterSeconds) seconds...")
                sleep(retryAfterSeconds)
            }
            
        } while status != CKAccountStatus.available
        
        observer.onCompleted()
        
        return Disposables.create()
    }
}

fileprivate func checkAccountStatus(container: CKContainer, onError: @escaping (Error)->()) -> CKAccountStatus {
    var status = CKAccountStatus.couldNotDetermine
    
    waitForCallback { STOP_WAITING in
        print("iCloudRx: going to check account status")
        
        container.accountStatus() { _status, error in // CKAccountStatus, Error?
            status = _status
            if let error = error {
                onError(error)
            }
            STOP_WAITING()
        }
    }
    
    //return CKAccountStatus.couldNotDetermine
    return status
}
