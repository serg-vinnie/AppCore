//
//  LocalizatorExtensions.swift
//  AppCore
//
//  Created by Loki on 6/20/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import AsyncNinja

public extension LocalizatorService {
    enum Language : String, CaseIterable {
        case en
        case ua
        case ru
        
        public static var system : Language {
            let mainLang = Locale.preferredLanguages[0]
            
            switch (mainLang)
            {
            case _ where mainLang.hasPrefix("en"):  return .en
            case _ where mainLang.hasPrefix("uk"):  return .ua
            case _ where mainLang.hasPrefix("ru"):  return .ru
            default: return .en
            }
        }
    }
}

public extension StatesService {
    var localizationDidChange : Channel<LocalizationState, Void> {
        return self.subscribeFor(key: LOCALIZATION_STATE, valueOfType: LocalizationState.self)
    }
}

public extension ExecutionContext {
    func localize(id: String) -> Channel<String?,Void> {
        return AppCore.states.localizationDidChange
            .map(context: self) { _, loc in loc.stringBy(id: id) }
    }
    
    func localize(id: String) -> Channel<String,Void> {
        return AppCore.states.localizationDidChange
            .map(context: self) { _, loc in loc.stringBy(id: id) }
    }
}
