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

open class CollectionService<Entity> : NinjaContext.Main where Entity : CollectionEntity {
    let alias : String
    public let db : RealmBackendService
    public let thumbnails : ThumbnailService
    public let signals = SignalsService()
    
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
        return db.allObjects(ofType: Entity.self)
    }
    
    func subscribeTo(signals: SignalsService) {
        signals.subscribeFor(CollectionSignal.Create.self)
            .onUpdate(context: self) { ctx, signal in ctx.addItem() {_ in} }
        signals.subscribeFor(CollectionSignal.Delete.self)
            .onUpdate(context: self) { ctx, signal in ctx.deleteItem(key: signal.key) }
        signals.subscribeFor(CollectionSignal.Rename.self)
            .onUpdate(context: self) { ctx, signal in ctx.rename(key: signal.key, with: signal.newName) }
        signals.subscribeFor(CollectionSignal.SetUrl.self)
            .onUpdate(context: self) { ctx, signal in ctx.setPath(key: signal.key, url: signal.url) }
        signals.subscribeFor(CollectionSignal.SetIcon.self)
            .onUpdate(context: self, executor: Executor.immediate) { ctx, signal in ctx.setIcon(key: signal.key, url: signal.url) }
    }
    
    @discardableResult
    public func addItem(block: (Entity) -> Void) -> Entity {
        let entity = Entity()
        entity.alias = "\(alias) \(db.allObjects(ofType: Entity.self).count)"
        
        block(entity)
        
        db.add(object: entity)
        return entity
    }
    
    public func getItemBy(alias: String, caseSensetive: Bool, createIfNecessary: Bool) -> Entity? {
        if caseSensetive {
            if let entity = db.realm.objects(Entity.self).first(where: { $0.alias == alias }) {
                return entity
            }
        } else {
            if let entity = db.realm.objects(Entity.self).first(where: { $0.alias.uppercased() == alias.uppercased() }) {
                return entity
            }
        }
        
        if createIfNecessary {
            return addItem() { $0.alias = alias }
        }
        
        return nil
    }
    
    public func deleteItem(key: String) {
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
                if newName.count > 0 {
                    entity.alias = newName
                } else {
                    let tmp = entity.alias
                    entity.alias = tmp
                }
                
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
                entity.path = url.path
                entity.pathIsValid = validate(url: url)
            }
        }catch {
            AppCore.log(title: "CollectionService", error: error)
        }
    }
    
    func setIcon(key:String, url: URL) {
        guard let entity : Entity = db.objectWith(key: key)  else { return }
        
        do {
            try db.realm.write {
                entity.iconPath = thumbnails.replace(file: entity.iconPath, with: url) ?? ""
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
