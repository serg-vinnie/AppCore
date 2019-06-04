//
//  OS.swift
//  Coherent
//
//  Created by Loki on 6/11/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

public func detectOS() -> String {
    #if os(iOS)
    return "iOS"
    #elseif os(macOS)
    return "macOS"
    #elseif os(watchOS)
    return "watchOS"
    #elseif os(tvOS)
    return "tvOS"
    #endif
}

#if os(iOS)
public func deviceUUID() -> uuid_t {
    UIDevice.current.identifierForVendor?.uuid
}
#endif

public func deviceName() -> String {
    #if os(iOS)
    
    return UIDevice.current.name
    
    #elseif os(macOS)
    
    return Host.current().localizedName ?? "NoName"
    
    #endif
}
