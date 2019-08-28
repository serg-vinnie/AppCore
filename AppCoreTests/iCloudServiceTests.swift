//
//  iCloudServiceTests.swift
//  AppCoreTests
//
//  Created by Loki on 8/27/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import XCTest
import CloudKit
import AsyncNinja
@testable import AppCore

class iCloudServiceTests: XCTestCase {
    
    let recordType = "TestRecord"
    let cloudPrivate = AppCore.container.resolve(iCloundNinjaPrivate.self)!

    override func setUp() {
        XCTAssert(cloudPrivate.container.status().wait().success! == .available)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDelete() {
        //cloudPrivate.batchSize = 100
        let (result, completion) = cloudPrivate.deleteRecordsOf(type: recordType).waitForAll()
    }
    
    func testFetch() {
        cloudPrivate.batchSize = 100
        let (result, _) = cloudPrivate.fetchRecordsOf(type: recordType).waitForAll()
        print(result.map { $0.count } )
    }
    
    func testPushFetchDelete() {
        let COUNT = 5
        
        let cloudDB = cloudPrivate.cloudDB
        let pushResult = cloudDB.push(records: fakeRecords(count: COUNT)).wait().success!
        XCTAssert(pushResult.count == COUNT)
        sleep(3)
        
        let IDs = pushResult.map { $0.recordID }
        
        let fetchResult = cloudDB.fetch(IDs: IDs).wait().success!
        XCTAssert(fetchResult.count == COUNT)
        
        let deleteResult = cloudDB.delete(IDs: IDs).wait()
        XCTAssert(deleteResult.success?.count == COUNT)
    }
    
    func testQuery() {
        let (_,delComp0) = cloudPrivate.deleteRecordsOf(type: recordType).waitForAll()
        XCTAssert(delComp0.success != nil)
        
        let PUSH_COUNT = 350
        cloudPrivate.batchSize = 100
        let (pushResult, pushComp) = cloudPrivate.push(records: fakeRecords(count: PUSH_COUNT)).waitForAll()
        XCTAssert(pushComp.success != nil)
        XCTAssert(pushResult.flatMap { $0 }.count == PUSH_COUNT)
        
        sleep(3)
        
        let(queryResult, queryComp) = cloudPrivate.fetchRecordsOf(type: recordType).waitForAll()
        XCTAssert(queryComp.success != nil)
        XCTAssert(queryResult.flatMap { $0 }.count == PUSH_COUNT)
        
        let (delResult, delComp) = cloudPrivate.deleteRecordsOf(type: recordType).waitForAll()
        XCTAssert(delComp.success != nil)
        XCTAssert(delResult.flatMap { $0 }.count == PUSH_COUNT)
        print("delResult \(delResult.flatMap { $0 }.count)")
    }
    
    func testPushAndDelete2() {
        let COUNT = 8
        
        
        let cloudDB = cloudPrivate.cloudDB
        cloudPrivate.batchSize = 2
        let (result, completion) = cloudPrivate.split(items: fakeRecords(count: COUNT))
            .flatMap(executor: .iCloudFlatMap, bufferSize: .specific(4)) { cloudDB.push(records: $0).asChannel(executor: .iCloud) }
            .waitForAll()
        let records = result.flatMap { $0 }
        
        XCTAssert(completion.success != nil)
        XCTAssert(result.count == COUNT / cloudPrivate.batchSize)
        XCTAssert(records.count == COUNT)
        
        let deleteResult = cloudDB.delete(IDs: records.map { $0.recordID }).wait()
        XCTAssert(deleteResult.success?.count == COUNT)
    }
    

    func testPushOld() {
        let cloudDB = cloudPrivate.cloudDB
        
        let pushResult = cloudDB.push(records: fakeRecords(count: 5)).wait()
        
    
        
        
        /// PUSH with many batches
        cloudPrivate.batchSize = 2
        let count = 10
        let (result, completion) = cloudPrivate.push(records: fakeRecords(count: count)).waitForAll()
        let records = result.flatMap { $0 }
        
        print("result \(result.count)")
        
        XCTAssert(completion.success != nil)
        XCTAssert(result.count == count / cloudPrivate.batchSize)
        XCTAssert(records.count == count)
        
        /// PUSH with single batch
        cloudPrivate.batchSize = 20
        let (result2, completion2) = cloudPrivate.push(records: fakeRecords(count: count)).waitForAll()
        let records2 = result.flatMap { $0 }
        
        XCTAssert(completion2.success != nil)
        XCTAssert(result2.count == 1)
        XCTAssert(records2.count == count)
        
        // wait for server processing
        //sleep(3)
        
        //let allRecords = records + records2
        //let allIDs = allRecords.map { $0.recordID }
        
        //        let (resultFetch, completeFetch) = cloudPrivate.fetchRecordsOf(type: recordType).waitForAll()
        //        let recordsFetch = resultFetch.flatMap { $0 }
        //
        //        XCTAssert(recordsFetch.count == allRecords.count)
        
        //let fetchAll = cloudPrivate.fetchRecordsOf(type: recordType).map { $0.map { $0.recordID } }
        //_ = cloudPrivate.delete(IDs: fetchAll).waitForAll()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension iCloudServiceTests {
    func fakeRecords(count: Int) -> [CKRecord] {
        var records = [CKRecord]()
        for _ in 0 ..< count {
            records.append(CKRecord(recordType: recordType))
        }
        return records
    }
}

func flatMapTest(arg: String) -> Channel<String,Void> {
    return producer(executor: Executor.iCloud) { producer in
        for i in 0...100 {
            producer.update("_\(arg)_\(i)")
        }
    }
}




