
//
//  iCloudNotificationChanges.swift
//  KeyKey
//
//  Created by Loki on 3/29/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit

public class iCloudChangeFetcher {
    public private(set) var recordIDsCreated = [CKRecord.ID]()
    public private(set) var recordIDsUpdated = [CKRecord.ID]()
    public private(set) var recordIDsDeleted = [CKRecord.ID]()
    
    public private(set) var container: CKContainer
    public private(set) var changeTokenKey: String
    
    private var isBusy = false
    private var tmpChangeToken : CKServerChangeToken?
    
    public var dbgSummary: String { return "CREATED \(recordIDsCreated.count); UPDATED \(recordIDsUpdated.count); DELETED \(recordIDsDeleted.count) " }
    
    public init(container: CKContainer, changeTokenKey: String){
        self.container = container
        self.changeTokenKey = changeTokenKey
    }
    
    public func perform(onComplete: @escaping (Bool)->Void) {
        if isBusy {
            onComplete(false)
            return
        }
        
        let fetch = CKFetchNotificationChangesOperation(previousServerChangeToken: serverChangeToken)

        fetch.notificationChangedBlock = { notification in
            guard let notification = notification as? CKQueryNotification else { return }
            
            if let recordID = notification.recordID {
                switch notification.queryNotificationReason {
                case .recordCreated: self.recordIDsCreated.append(recordID)
                case .recordUpdated: self.recordIDsUpdated.append(recordID)
                case .recordDeleted: self.recordIDsDeleted.append(recordID)
                @unknown default:
                    fatalError()
                }
            }
        }
        
        fetch.fetchNotificationChangesCompletionBlock = { newToken, error in
            if let error = error {
                print("fetchNotificationChangesCompletionBlock ERROR: \(error)")
                onComplete(false)
            } else if let token = newToken {
                self.tmpChangeToken = token
                print("iCloud NEW CHANGE TOKEN received. Call saveTempToken to save it")
                onComplete(true)
            }
            
            self.isBusy = false
        }
        
        container.add(fetch)
    }
    
    public func saveTempToken() {
        if let token = tmpChangeToken {
            serverChangeToken = token
            tmpChangeToken = nil
            print("iCloud CHANGE TOKEN saved")
        }
    }
    
    public func deleteServerToken() {
        self.serverChangeToken = nil
    }
}

public extension iCloudChangeFetcher {
    var serverChangeToken: CKServerChangeToken? {
        get {
            guard let data = UserDefaults.standard.value(forKey: changeTokenKey) as? Data else {
                return nil
            }
            
            guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else {
                return nil
            }
            
            return token
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                UserDefaults.standard.set(data, forKey: changeTokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: changeTokenKey)
            }
        }
    }
}
