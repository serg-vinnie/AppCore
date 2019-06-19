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

class LocalizationEntity: Object {
    override static func primaryKey() -> String? { return "key" }
    
    @objc dynamic var key: String? = nil
    @objc dynamic var en: String? = nil
    @objc dynamic var ru: String? = nil
    @objc dynamic var ua: String? = nil
}

public class LocalizatoinService {
    let realm : Realm
    var lang = Language.en
    
    public init(url: URL, schemaVersion: UInt64) {
        var config = Realm.Configuration.defaultConfiguration
        config.readOnly = true
        config.fileURL = url
        config.objectTypes = [LocalizationEntity.self]
        config.schemaVersion = schemaVersion
        //config.migrationBlock = { migration, oldVersion in }
        
        realm = try! Realm(configuration: config)
    }
    
    public func stringBy(id: String) -> String {
        guard let obj = realm.object(ofType: LocalizationEntity.self, forPrimaryKey: id)
            else { return "[wrong id]" }

        let en = obj.en ?? "[\(id)]"
        
        switch lang {
        case .en: return en
        case .ua: return obj.ua ?? en
        case .ru: return obj.ru ?? en
        }
    }
}

public extension LocalizatoinService {
    enum Language {
        case en
        case ua
        case ru
    }
}
