//
//  Logger.swift
//  TaoGit
//
//  Created by UKS on 12.11.2019.
//  Copyright © 2019 Cheka Zuja. All rights reserved.
//

public protocol Logger {}

public extension Logger {
    func log(msg: String) {
        AppCore.log(title: String(describing: self), msg: msg)
    }

    func log(error: Error) {
        AppCore.log(title: String(describing: self), error: error)
    }
}
