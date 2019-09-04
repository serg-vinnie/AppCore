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

public func serialNumber() -> String {
    // Get the platform expert
    let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    
    // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
    let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0);
    
    // Release the platform expert (we're responsible)
    IOObjectRelease(platformExpert);
    
    // Take the unretained value of the unmanaged-any-object
    // (so we're not responsible for releasing it)
    // and pass it back as a String or, if it fails, an empty string
    return (serialNumberAsCFString?.takeUnretainedValue() as? String) ?? ""
}
