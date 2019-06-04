//
//  OperationHelper.swift
//  KeyKey
//
//  Created by Loki on 5/4/18.
//  Copyright © 2018 Sergiy Vynnychenko. All rights reserved.
//

import Foundation

public class OperationOrder {
    var lastOperation : Operation?
    
    public func addAsDependentOfPrevious(_ nextOperation: Operation) {
        if let prev = lastOperation {
            nextOperation.addDependency(prev)
        }
    }
}
