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

public extension CKContainer {
    func status() -> Future<CKAccountStatus> {
        return promise() { [weak self] promise in
            
            self?.accountStatus{ status, error in // CKAccountStatus, Error?
                promise.succeed(status)
                if let error = error {
                    promise.fail(error)
                }
            }
            
        }
    }
}
