//
//  LocalizatorProtocol.swift
//  AppCore
//
//  Created by Loki on 6/20/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation

public protocol LocalizatorProtocol {
    var lang : LocalizatorService.Language { get }
    func stringBy(id: String) -> String
}

public struct LocalizationState { // states service accespts only structs
    private let localizator : LocalizatorProtocol
    init(localizator: LocalizatorProtocol) {
        self.localizator = localizator
    }
    
    public func stringBy(id: String) -> String {
        return localizator.stringBy(id: id).withReplacing(from: "/n", to: "\n")
    }
    
    public var lang : LocalizatorService.Language { return localizator.lang }
}
