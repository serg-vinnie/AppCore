//
//  DispatchHelpers.swift
//  KeyKey
//
//  Created by Loki on 5/11/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public func waitForCallback(code: @escaping ( @escaping ()->Void )->Void) {
    let DISPATCH_GROUP = DispatchGroup()
    DISPATCH_GROUP.enter()
    
    code {
        DISPATCH_GROUP.leave()
    }
    
    DISPATCH_GROUP.wait()
}
