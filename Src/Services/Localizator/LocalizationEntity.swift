//
//  LocalizationEntity.swift
//  AppCore
//
//  Created by Loki on 6/20/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Realm
import RealmSwift

class LocalizationEntity: Object {
    override static func primaryKey() -> String? { return "key" }
    
    @objc dynamic var key: String? = nil
    @objc dynamic var en: String? = nil
    @objc dynamic var ru: String? = nil
    @objc dynamic var ua: String? = nil
}
