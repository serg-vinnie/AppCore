//
//  RealmSingleton.swift
//  Coherent
//
//  Created by Loki on 6/1/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
import RealmSwift

// usage: private lazy var data : TrackerEntity = { return RealmSingleton<TrackerEntity>(realm: realm).object }()

public class RealmSingleton<T> where T : Object {
    public let object : T
    public init(realm: Realm) {
        let data_result = realm.objects(T.self)
        if data_result.count == 0 {
            object = T()
            try! realm.write {
                realm.add(object)
            }
        } else if data_result.count == 1{
            object = data_result[0]
        } else {
            fatalError()
        }
    }
}
