//
//  CollectionEntity.swift
//  AppCore
//
//  Created by Loki on 4/2/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import RealmSwift


public protocol CollectionBaseEntity {
    var key         : String    { get set }
}

public extension CollectionBaseEntity {
    var optionalAlias : String? {
        get { return (self as? CollectionAliasProperty)?.alias }
    }
    
    var optionalIconPath : String? {
        get { return (self as? CollectionIconPathProperty)?.iconPath }
        set { if var entity = self as? CollectionIconPathProperty {
                entity.iconPath = newValue ?? ""
            }
        }
    }
    
    func trySet(alias: String) {
        if var entity = self as? CollectionAliasProperty {
            entity.alias = alias
        }
    }
    
    func trySet(path: String) {
        if var entity = self as? CollectionPathProperty {
            entity.path = path
        }
    }
    
    func trySet(pathIsValid: Bool) {
        if var entity = self as? CollectionPathProperty {
            entity.pathIsValid = pathIsValid
        }
    }
    
    func trySet(iconPath: String) {
        if var entity = self as? CollectionIconPathProperty {
            entity.iconPath = iconPath
        }
    }
}


///////////////////////////////////////////

public protocol CollectionAliasProperty {
    var alias       : String    { get set }
}

public protocol CollectionPathProperty {
    var path        : String    { get set }
    var pathIsValid : Bool      { get set }
}

public protocol CollectionIconPathProperty {
    var iconPath    : String    { get set }
}

@objcMembers open class CollectionEntity: Object,
    CollectionBaseEntity,
    CollectionAliasProperty,
    CollectionPathProperty,
    CollectionIconPathProperty
{
    public override static func primaryKey() -> String? { return "key" }
    
    public dynamic var key                 : String    = UUID().uuidString
    public dynamic var alias               : String    = ""
    public dynamic var path                : String    = ""
    public dynamic var pathIsValid         : Bool      = false
    public dynamic var iconPath            : String    = ""
}
