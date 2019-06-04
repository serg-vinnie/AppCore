//
//  iCloudQuery.swift
//  KeyKey
//
//  Created by Loki on 4/13/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit

open class iCloudQuery {
    public private(set) var cloudDB: CKDatabase
    public private(set) var isBusy = false
    public private(set) var fetchedRecordsNumber : Int = 0
    
    private var onAllQueriesCompleted : ((Bool)->())?
    
    private(set) var resultsLimit = CKQueryOperation.maximumResults // default is 100
    public var onRecordFetched: ((CKRecord) -> Swift.Void)?
    public var onQueryStep: ((CKQueryOperation.Cursor?, Error?) -> Swift.Void)?
    
    public init(cloudDB: CKDatabase){
        self.cloudDB = cloudDB
    }
    
    open func perform(query: CKQuery, onComplete: @escaping (Bool)->Void) {
        if isBusy {
            onComplete(false)
            return
        }
        isBusy = true
        fetchedRecordsNumber = 0
        onAllQueriesCompleted = onComplete
        add(queryOperation: CKQueryOperation(query: query))
    }
    
    private func add(queryOperation: CKQueryOperation) {
        queryOperation.resultsLimit = resultsLimit
        queryOperation.queryCompletionBlock = onQueryStep
        queryOperation.recordFetchedBlock = { record in
            self.fetchedRecordsNumber += 1
            self.onRecordFetched?(record)
        }
        cloudDB.add(queryOperation)
    }
    
    public func continueQuery(cursor: CKQueryOperation.Cursor?) {
        if let cursor = cursor {
            self.add(queryOperation: CKQueryOperation(cursor: cursor))
        } else {
            isBusy = false
            self.onAllQueriesCompleted?(true)
        }
    }
}
