//
//  LocalizatorExtensions.swift
//  AppCore
//
//  Created by Loki on 6/20/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import AsyncNinja

public extension LocalizatorService {
    enum Language : String {
        case en
        case ua
        case ru
    }
}

public extension StatesService {
    var localizationDidChange : Producer<LocalizatorProtocol, Void> {
        return self.subscribeFor(key: LOCALIZATION_STATE, valueOfType: LocalizatorProtocol.self)
    }
}
