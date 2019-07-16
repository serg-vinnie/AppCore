//
//  iCloudNinja-Fetch.swift
//  SwiftCore
//
//  Created by Loki on 1/11/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import AsyncNinja

public extension CKDatabase {
    func fetch(IDs: [CKRecord.ID]) -> Future<[CKRecord.ID:CKRecord]> {
        log(msg:"going to fetch \(IDs.count) records")
        return promise() { [weak self] promise in
            let fetch = CKFetchRecordsOperation(recordIDs: IDs)
            
            fetch.fetchRecordsCompletionBlock = { records, error in
                if let records = records        { log(msg: "\(records.count) fetched"); promise.succeed(records) }
                if let error = error            { log(error: error);                    promise.fail(error) }
            }
            
            self?.add(fetch)
        }
    }
}

//func iCloudNinjaFetch(ids: [CKRecord.ID], cloudDB: CKDatabase) -> Future<[CKRecord.ID:CKRecord]> {
//    let promise = Promise<[CKRecord.ID:CKRecord]>()
//
//    let fetch = CKFetchRecordsOperation(recordIDs: ids)
//    fetch.fetchRecordsCompletionBlock = { records, error in
//        if let records = records        { promise.succeed(records) }
//        if let error = error            { log(error: error); promise.fail(error) }
//    }
//    cloudDB.add(fetch)
//
//    return promise
//}

fileprivate func log(msg: String) {
    AppCore.log(title: "iCloudNinja", msg: msg, thread: true)
}

fileprivate func log(error: Error) {
    AppCore.log(title: "iCloudNinja", error: error, thread: true)
}
