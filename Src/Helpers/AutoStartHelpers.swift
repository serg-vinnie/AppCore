//
//  AutoStartHelpers.swift
//  SwiftCore
//
//  Created by Loki on 1/3/19.
//  Copyright © 2019 checkazuja. All rights reserved.
//

import AppKit
import ServiceManagement

// https://theswiftdev.com/2017/10/27/how-to-launch-a-macos-app-at-login/

public class AutoStartHelper {
    let hostAppId : String
    let NotificationAppDidStart: Notification.Name
    
    var launcherId : String { return hostAppId + "Launcher" }
    
    public init(hostAppId: String) {
        self.hostAppId = hostAppId
        NotificationAppDidStart = Notification.Name(hostAppId + "DidStart")
    }
    
    public func killLauncher() -> Bool {
        if isAppRunning(id: launcherId) {
            DistributedNotificationCenter.default()
                .postNotificationName(NotificationAppDidStart, object: hostAppId, userInfo: nil, options: .deliverImmediately)

            return true
        } else {
            return false
        }
    }
    
    public func runLauncherAndListenForTermination() {
        if !isAppRunning(id: hostAppId) {
            DistributedNotificationCenter.default()
                .addObserver(self, selector: #selector(terminate), name: NotificationAppDidStart, object: nil)
            
            NSWorkspace.shared.launchApplication(hostAppPath())
        } else {
            terminate()
        }
    }
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }
    
    func hostAppPath() -> String {
        return Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path
    }
    
    public func isAppRunning(id: String) -> Bool {
        for app in NSWorkspace.shared.runningApplications {
            guard let bundleId = app.bundleIdentifier else { continue }
            
            if bundleId == id {
                return true
            }
        }
        return false
    }
    
    public func launchAtLogIn(_ enabled: Bool) {
        print("SET LAUNCH AT STARTUP : \(enabled) for \(launcherId)")
        #if !DEBUG
        if !SMLoginItemSetEnabled(launcherId as CFString, enabled) {
            print("SMLoginItemSetEnabled failed \(launcherId)")
        }
        #endif
    }
}
