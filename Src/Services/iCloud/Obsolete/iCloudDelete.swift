//
//  iCloudDelete.swift
//  KeyKey
//
//  Created by Loki on 3/27/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import CloudKit

public class iCloudDelete : iCloudQuery {
    
    private(set) var deletedRecordsNumbers : Int = 0
    
    private var recordIDsToDelete = [CKRecord.ID]()
    
    override public init(cloudDB: CKDatabase){
        super.init(cloudDB: cloudDB)
        onRecordFetched = recordFetched
        onQueryStep = deleteQueryStep
    }
    
    override public func perform(query: CKQuery, onComplete: @escaping (Bool)->Void) {
        if isBusy {
            onComplete(false)
            return
        }
        deletedRecordsNumbers = 0
        super.perform(query: query, onComplete: onComplete) 
    }
    
    private func deleteQueryStep(cursor: CKQueryOperation.Cursor?, error: Error?) {
        print("----------------------")
        if let error = error {
            print("Error: deleteQueryStep - \(error)")
        }
        
        let delete = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsToDelete)
        delete.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
            self.deletedRecordsNumbers += deletedRecordIDs?.count ?? 0
        }
        delete.completionBlock = {
            self.recordIDsToDelete.removeAll()
            self.continueQuery(cursor: cursor)
        }
        cloudDB.add(delete)
    }
    
    private func recordFetched(record: CKRecord) {
        print("RECORD fetched: \(record.recordID.recordName)")
        recordIDsToDelete.append(record.recordID)
    }
}
