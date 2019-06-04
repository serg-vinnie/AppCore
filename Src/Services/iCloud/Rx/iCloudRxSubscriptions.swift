//
//  iCloudRxSubscriptions.swift
//  KeyKey
//
//  Created by Loki on 5/10/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit
import RxSwift

public class iCloudRxSubscriptions {
    public       let bag                    = DisposeBag()
    public       var defaultNotification    = CKSubscription.NotificationInfo()
    private(set) var cloudDB                : CKDatabase
    private(set) var subscriptions          = [CKSubscription]()
    private(set) var wasFetched             = false
    public       var count                  : Int { return subscriptions.count }
    
    public init(cloudDB: CKDatabase){
        self.cloudDB = cloudDB
        
        defaultNotification.shouldSendContentAvailable = true
        defaultNotification.soundName = ""
    }
        
    public func subscribe(to subscription: CKSubscription) -> Observable<Void> {
        return Observable<Void>.create { [weak self] subscribe in
            
            if self != nil {
                subscription.notificationInfo = self!.defaultNotification
                iCloudRxSubscribe(to: subscription, cloudDB: self!.cloudDB)
                    .subscribe(
                        onNext:      { self?.subscriptions.append($0) },
                        onError:     { subscribe.onError($0) },
                        onCompleted: { subscribe.onCompleted() })
                    .disposed(by: self!.bag)
            }
            return Disposables.create()
        }
    }
    
    public func unsubsribe(from subscriptionID: String) -> Observable<Void> {
        return Observable<Void>.create { [weak self] subscribe in
            
            if self != nil {
                iCloudRxUnsubscribe(from: subscriptionID, cloudDB: self!.cloudDB)
                    .subscribe(
                        onNext:      { id in self?.subscriptions.removeFirst(where: { $0.subscriptionID == id }) },
                        onError:     { subscribe.onError($0) },
                        onCompleted: { subscribe.onCompleted() }
                    )
                    .disposed(by: self!.bag)
            }
            return Disposables.create()
        }
    }
    
    public func fetch() -> Observable<CKSubscription> {
        return Observable<CKSubscription>.create { [weak self] subscribe in
            
            if self != nil {
                iCloudRxFetchSubscriptions(cloudDB: self!.cloudDB)
                    .subscribe(
                        onNext:      { self?.subscriptions.append($0); subscribe.onNext($0) },
                        onError:     { subscribe.onError($0) },
                        onCompleted: { subscribe.onCompleted() })
                    .disposed(by: self!.bag)
            }
            return Disposables.create()
        }
    }
   
    public func unsubscribeFromAll() -> Observable<Void> {
        return Observable<Void>.create { [weak self] subscribe in
            
            if self != nil {
                let IDs = self!.subscriptions.map { $0.subscriptionID }
                iCloudRxDeleteSubscriptions(cloudDB: self!.cloudDB, IDs: IDs)
                    .subscribe(
                        onNext:      { ids in
                            if let ids = ids {
                                for id in ids {
                                    self?.subscriptions.removeFirst(where: { $0.subscriptionID == id })
                                }
                            }},
                        onError:     { subscribe.onError($0) },
                        onCompleted: { subscribe.onCompleted() }
                    )
                    .disposed(by: self!.bag)
            }
            
            return Disposables.create()
        }
    }
}
