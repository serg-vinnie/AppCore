//
//  ViewController.swift
//  TestHost
//
//  Created by Loki on 8/27/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Cocoa
import AsyncNinja
@testable import AppCore

class ViewController: NSViewController {
    
    let cloudPrivate = AppCore.container.resolve(iCloundNinjaPrivate.self)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func test(_ sender: Any) {
        let ITEMS_TOTAL = 4000
        
        var items = [Int]()
        for i in 0..<ITEMS_TOTAL {
            items.append(i)
        }
        
        
        cloudPrivate.batchSize = 300
        cloudPrivate.split(items: items)
            .flatMap(executor: .iCloudFlatMap, bufferSize: .specific(0)) { fakePush(items: $0).asChannel(executor: .immediate) } //
            .onUpdate { print("update _ \($0)") }
        

    }
    
}

enum TestErrors : Error {
    case TooManyItems
}

public func fakePush(items: [Int]) -> Future<[String]> {
    return promise(executor: .iCloud) { promise in
        DispatchQueue.global().async {
            sleep(1)
            if items.count <= 400 {
                promise.succeed(items.map { "\($0)" }, from: .iCloud)
            } else {
                promise.fail(TestErrors.TooManyItems, from: .iCloud)
            }
        }
    }
}
