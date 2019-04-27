//
//  RealmDataSource.swift
//  AppCore
//
//  Created by Loki on 4/27/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja
import RealmSwift

class RealmDataSource<EntityType: Object> {
    weak var producer: Producer<(AnyRealmCollection<EntityType>, RealmChangeset?), Void>?
    
}
