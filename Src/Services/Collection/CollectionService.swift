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

private func fileName(alias: String, env: ServiceEnvironment) -> String {
    switch env {
    case .Release: return alias
    case .Debug:   return "\(alias)_dbg.realm"
    case .Test:    return "\(alias)_tst.realm"
    }
}

open class CollectionService<Entity> : Ninja where Entity : CollectionEntity {
    let alias : String
    public let db : RealmBackendService
    public let thumbnails : ThumbnailService
    public let signals = SignalsService()
    
    public init(alias: String, env: ServiceEnvironment) {
        self.alias = alias
        var config = Realm.Configuration()
        config.fileURL         = FS.urlFor(file: fileName(alias: alias, env: env))
        config.objectTypes     = [Entity.self] 
        db = RealmBackendService(config: config, serviceName: "CollectionService")
        
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
            .onUpdate(context: self) { ctx, signal in ctx.addRepo() }
        signals.subscribeFor(CollectionSignal.Delete.self)
            .onUpdate(context: self) { ctx, signal in ctx.deleteRepoWith(key: signal.key) }
        signals.subscribeFor(CollectionSignal.Rename.self)
            .onUpdate(context: self) { ctx, signal in ctx.rename(key: signal.key, with: signal.newName) }
        signals.subscribeFor(CollectionSignal.SetUrl.self)
            .onUpdate(context: self) { ctx, signal in ctx.setPath(key: signal.key, url: signal.url) }
        signals.subscribeFor(CollectionSignal.SetIcon.self)
            .onUpdate(context: self) { ctx, signal in ctx.setIcon(key: signal.key, url: signal.url) }
    }
    
    public func addRepo() {
        let repo = Entity()
        repo.alias = "repo \(db.allObjects(ofType: Entity.self).count)"
        
        db.add(object: repo)
    }
    
    func deleteRepoWith(key: String) {
        AppCore.log(title: "CollectionService" , msg: "delete \(key)", thread: true)
        
        guard let repo : Entity = db.objectWith(key: key)  else { return }
        db.delete(object: repo)
    }
    
    func rename(key: String, with newName: String) {
        guard let repo : Entity = db.objectWith(key: key)  else { return }
        
        do {
            try db.realm.write {
                if newName.count > 0 {
                    repo.alias = newName
                } else {
                    let tmp = repo.alias
                    repo.alias = tmp
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
}
