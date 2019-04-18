//
//  ThumbnailService.swift
//  TaoGit
//
//  Created by Loki on 4/2/19.
//  Copyright © 2019 Cheka Zuja. All rights reserved.
//

import Foundation

public class ThumbnailService { // bla
    public let url : URL
    
    public init(folder: String = "") {
        url = FS.appFolder().appendingPathComponent("Thumbnails").appendingPathComponent(folder)
        FS.makeSureDirExist(url.path)
    }
    
    public func add( url: URL) -> String? {
        guard url.isFileURL else { return nil }

        var file = url
        let ext = "." + file.pathExtension
        file.deletePathExtension()
        
        let dst = self.url.appendingPathComponent(file.lastPathComponent + UUID().uuidString + ext)
        
        AppCore.log(title: "ThumbnailService", msg: dst.path)
        AppCore.log(title: "ThumbnailService", msg: dst.lastPathComponent)
        
        let folder = dst.deletingLastPathComponent()
        FS.makeSureDirExist(folder.path)
        FS.copy(from: url, to: dst)
        
        return dst.lastPathComponent
    }
    
    public func replace(file: String, with url: URL) -> String? {
        FS.delete(self.url.appendingPathComponent(file))
        return add(url: url)
    }
    
}
