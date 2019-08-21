//
//  CollectionService.swift
//  AppCore
//
//  Created by Loki on 4/2/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import RealmSwift
import AsyncNinja

open class CollectionService<Entity> : NinjaContext.Main where Entity : Object, Entity: CollectionBaseEntity {
    let alias : String
    public let db : RealmBackendService
    public let thumbnails : ThumbnailService
    public let signals = SignalsService()
    open var filter : NSPredicate? { return nil }
    
    public init(alias: String, db: RealmBackendService) {
        self.alias = alias
        self.db = db
        
        thumbnails = ThumbnailService(folder: alias)
        
        super.init()
        
        subscribeTo(signals: signals)
    }
    
    deinit {
        AppCore.log(title: "CollectionService - \(alias)", msg: "deinit")
    }
    
    public func queryAllItems() -> Results<Entity> {
        if let predicate = filter {
            return db.allObjects(ofType: Entity.self).filter(predicate)
        }
        return db.allObjects(ofType: Entity.self)
    }
    
    func subscribeTo(signals: SignalsService) {
        signals.subscribeFor(Signal.Collection.Create.self)
            .onUpdate(context: self) { ctx, signal in ctx.addItem() {_ in} }
        signals.subscribeFor(Signal.Collection.Delete.self)
            .onUpdate(context: self) { ctx, signal in ctx.deleteItem(key: signal.key) }
        signals.subscribeFor(Signal.Collection.Rename.self)
            .onUpdate(context: self) { ctx, signal in ctx.rename(key: signal.key, with: signal.newName) }
        signals.subscribeFor(Signal.Collection.SetUrl.self)
            .onUpdate(context: self) { ctx, signal in ctx.setPath(key: signal.key, url: signal.url) }
        signals.subscribeFor(Signal.Collection.SetIcon.self)
            .onUpdate(context: self, executor: Executor.immediate) { ctx, signal in ctx.setIcon(key: signal.key, url: signal.url) }
    }
    
    @discardableResult
    public func addItem(block: (Entity) -> Void) -> Entity {
        let entity = Entity()
        
        if var entity = entity as? CollectionAliasProperty {
            entity.alias = "\(alias) \(db.allObjects(ofType: Entity.self).count)"
        }
        
        
        block(entity)
        
        db.add(object: entity)
        return entity
    }
    
    public func getItemBy(alias: String, caseSensetive: Bool, createIfNecessary: Bool) -> Entity? {
        if caseSensetive {
            if let entity = db.realm.objects(Entity.self).first(where: { $0.optionalAlias == alias }) {
                return entity
            }
        } else {
            if let entity = db.realm.objects(Entity.self).first(where: { $0.optionalAlias?.uppercased() == alias.uppercased() }) {
                return entity
            }
        }
        
        if createIfNecessary {
            return addItem() { $0.trySet(alias: alias) }
        }
        
        return nil
    }
    
    open func deleteItem(key: String) {
        AppCore.log(title: "CollectionService - \(alias)" , msg: "delete \(key)", thread: true)
        
        guard let entity : Entity = db.objectWith(key: key)  else { return }
        db.delete(object: entity)
    }
    
    public func deleteAll() {
        db.deleteAll(type: Entity.self);
    }
    
    public func getItemBy(key: String) -> Entity? {
        return db.objectWith(key: key)
    }
    
    public func rename(key: String, with newName: String) {
        guard let entity : Entity = db.objectWith(key: key)  else { return }
        
        do {
            try db.realm.write {
                entity.trySet(alias: newName)
            }
        }catch {
            AppCore.log(title: "CollectionService", error: error)
        }
    }
    
    open func validate(url: URL) -> Bool {
        return true
    }
    
    func setPath(key: String, url: URL) {
        guard let entity : Entity = db.objectWith(key: key)  else { return }
        
        do {
            try db.realm.write {
                entity.trySet(path: url.path)
                entity.trySet(pathIsValid: validate(url: url))
            }
        }catch {
            AppCore.log(title: "CollectionService", error: error)
        }
    }
    
    func setIcon(key:String, url: URL) {
        guard var entity : Entity = db.objectWith(key: key)  else { return }
        
        do {
            try db.realm.write {
                entity.optionalIconPath = thumbnails.replace(file: entity.optionalIconPath ?? "", with: url)
            }
        }catch {
            AppCore.log(title: "CollectionService", error: error)
        }
    }
    
    public func thumbnailUrl(relativePath: String?) -> URL? {
        if let path = relativePath {
            return thumbnails.url.appendingPathComponent(path)
        } else {
            return nil
        }
    }
}
