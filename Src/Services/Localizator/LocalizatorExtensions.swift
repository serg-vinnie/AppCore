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
        
        public static var system : Language {
            switch (Locale.current.languageCode!)
            {
            case "en":  return .en
            case "uk":  return .ua
            case "ru":  return .ru
            default: return .en
            }
        }
    }
}

public extension StatesService {
    var localizationDidChange : Producer<LocalizatorProtocol, Void> {
        return self.subscribeFor(key: LOCALIZATION_STATE, valueOfType: LocalizatorProtocol.self)
    }
}
