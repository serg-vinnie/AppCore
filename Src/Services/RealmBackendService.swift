//
//  RealmBackendService.swift
//  SwiftCore
//
//  Created by Loki on 1/9/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxRealm

open class RealmBackendService {
    public let realm : Realm
    
    public init(config: Realm.Configuration) {
        do {
            realm = try Realm(configuration: config)
        } catch let error {
            AppCore.log(title: "RealmBackendService", msg: "can't init realm: \(config.fileURL!.path)", thread: true)
            AppCore.log(title: "RealmBackendService", error: error, thread: true)
            AppCore.log(title: "RealmBackendService", msg: "try delete files in app folder \n\(FS.appFolder().path)")
            fatalError()
        }
        
        #if DEBUG
        if let url = config.fileURL {
            log(msg: "realm file: \(url)")
        }
        if let memoryId = config.inMemoryIdentifier {
            log(msg: "realm memory id: \(memoryId)")
        }
        #endif
    }
    
    public func contains(key: String) -> Bool {
        return objectWith(key: key) != nil
    }
    
    public func objectWith<T>(key: String) -> T? where T : Object {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }
    
    public func write(block: ()->()) {
        do {
            try realm.write {
                block()
            }
        } catch {
            log(error: error)
        }
    }
    
    @discardableResult
    public func updateObjectWith<T>(key: String, ofType: T.Type, block: (T)->Void) -> Bool where T : Object {
        if let obj : T = objectWith(key: key) {
            do {
                try realm.write {
                    block(obj)
                }
                return true
            } catch {
                log(error: error)
            }
        }
        return false
    }
    
    public func allObjects<T>(ofType: T.Type) -> Results<T> where T : Object {
        return realm.objects(ofType.self)
    }
    
    public func add<T>(object: T, block: (T)->() = { _ in }) where T : Object {
        add(objects: [object]) { objects in
            guard let obj = objects.first as? T else { return }
            block(obj)
        }
    }
    
    public func add<T>(objects: [T], block: ([T]) -> () = { _ in }) where T : Object {
        do {
            try realm.write {
                realm.add(objects)
                block(objects)
            }
        } catch {
            log(error: error)
        }
    }
    
    public func delete<T>(object: T) where T : Object {
        delete(objects: [object])
    }
    
    public func delete<T>(objects: [T]) where T : Object {
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            log(error: error)
        }
    }
    
    public func deleteAll<T>(type: T.Type) where T : Object {
        for item in realm.objects(type) {
            try? realm.write {
                realm.delete(item)
            }
            
        }
    }
}

public extension RealmBackendService {
    func log(msg: String) {
        AppCore.log(title: "RealmBackendService", msg: msg, thread: true)
    }
    
    func log(error: Error) {
        AppCore.log(title: "RealmBackendService", error: error, thread: true)
    }
}
