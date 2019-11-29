//
//  Combine+AsyncNinja.swift
//  AppCore
//
//  Created by Serhii Vynnychenko on 11/29/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja
import Combine

@available(OSX 10.15, *)
public extension Published.Publisher {
    var asyncNinja : AsyncNinja.Channel<Value, Void> {
        return producer { producer in
            let sink = self.sink { value in
                producer.update(value)
            }
            producer._asyncNinja_retainUntilFinalization(sink)
        }
    }
}
