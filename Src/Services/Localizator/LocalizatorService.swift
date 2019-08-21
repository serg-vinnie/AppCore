//
//  LocalizationService.swift
//  AppCore
//
//  Created by Loki on 6/13/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Swinject


public let LOCALIZATION_STATE = "LOCALIZATION_STATE"

public class LocalizatorService : LocalizatorProtocol {
    public private(set) var lang = Language.en
    
    let realm : Realm
    let states : StatesService
    
    public init(url: URL, schemaVersion: UInt64, states: StatesService) {
        var config = Realm.Configuration.defaultConfiguration
        config.readOnly = true
        config.fileURL = url
        config.objectTypes = [LocalizationEntity.self]
        config.schemaVersion = schemaVersion
        //config.migrationBlock = { migration, oldVersion in }
        
        realm = try! Realm(configuration: config)
        
        self.states = states //container.resolve(StatesService.self)!
    }
    
    public func stringBy(id: String) -> String {
        guard let obj = realm.object(ofType: LocalizationEntity.self, forPrimaryKey: id)
            else { return "[\(id)]" }

        let en = obj.en ?? "[\(id)]"
        
        switch lang {
        case .en: return en
        case .ua: return obj.ua ?? en
        case .ru: return obj.ru ?? en
        }
    }
    
    public func set(lang: Language) {
        AppCore.log(title: "LocalizatorService", msg: "switching to: \(lang)")
        self.lang = lang
        states.set(value: LocalizationState(localizator: self), forKey: LOCALIZATION_STATE)
    }
}



