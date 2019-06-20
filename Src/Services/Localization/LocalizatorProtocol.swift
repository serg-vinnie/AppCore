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
