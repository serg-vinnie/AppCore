//
//  ReCloud-Auth.swift
//  SwiftCore
//
//  Created by Loki on 1/10/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import CloudKit
import RxSwift
import AsyncNinja

func iCloudNinjaAccountStatus(container: CKContainer) -> Future<CKAccountStatus> {
    let promise = Promise<CKAccountStatus>()
    container.accountStatus() { status, error in // CKAccountStatus, Error?
        promise.succeed(status)
        if let error = error {
            promise.fail(error)
        }
    }
    return promise
}
