//
//  CollectionEntity.swift
//  AppCore
//
//  Created by Loki on 4/2/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import RealmSwift

public protocol FileSystemEntity {
    var key         : String    { get set }
    var alias       : String    { get set }
    var path        : String    { get set }
    var pathIsValid : Bool      { get set }
    var iconPath    : String    { get set }
}

@objcMembers open class CollectionEntity: Object, FileSystemEntity {
    public override static func primaryKey() -> String? { return "key" }
    
    public dynamic var key                 : String    = UUID().uuidString
    public dynamic var alias               : String    = ""
    public dynamic var path                : String    = ""
    public dynamic var pathIsValid         : Bool      = false
    public dynamic var iconPath            : String    = ""
}
