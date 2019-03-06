/*
    MIT License

    Copyright (c) 2014 Sergiy Vynnychenko

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

import Foundation

public class FS {
    
    public static var home : URL { return FileManager.default.homeDirectoryForCurrentUser }
    
    public class func urlFor(file: String) -> URL {
        return appFolder().appendingPathComponent(file)
    }
    
    public class func resourcePath(_ file: String, ofType: String) -> String? {
        return Bundle.main.path(forResource: file, ofType: ofType)
    }
    
    public class func resourceURL(_ file: String, ofType: String) -> URL? {
        return Bundle.main.url(forResource: file, withExtension: ofType)
    }
    
    public class func applicationSupportFolder() -> String {
        return applicationSupportFolderURL().absoluteString
    }
    
    public class func appFolder() -> URL {
        #if os(iOS)
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        #elseif os(OSX)
        return applicationSupportFolderURL()
        #endif
    }
    
    public class func appSupportRoot(in mask: FileManager.SearchPathDomainMask) -> URL {
        do {
            return try FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: mask, appropriateFor: nil, create: false)
        } catch {
            fatalError()
        }
    }
    
    public class func applicationSupportFolderURL(in mask: FileManager.SearchPathDomainMask = .userDomainMask) -> URL {
        let fm = FileManager.default
        var appSupportURL: URL?
        do {
            appSupportURL = try fm.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: mask, appropriateFor: nil, create: true)
        } catch _ as NSError {
            appSupportURL = nil
        }
        
        let fullPath = appSupportURL!.appendingPathComponent(Bundle.main.bundleIdentifier!)
        
        do {
            try fm.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch _ {
            print("BLA")
        }
        
        return fullPath
    }
    
    public class func isDirExist(at url: URL) -> Bool {
        do {
            var rsrc: AnyObject?
            try (url as NSURL).getResourceValue(&rsrc, forKey: URLResourceKey.isDirectoryKey)
            if let isDirectory = rsrc as? NSNumber {
                return isDirectory == true
            }
        } catch { }
        
        return false
    }
    
    public class func isDirExist(_ path : String) -> Bool {
        guard let url = URL(string: "file:///" + path)
            else { return false }
        
        return isDirExist(at: url)
    }
    
    public class func files(at url: URL) -> [URL] {
        var urls : [URL] = []
        
        if isDirExist(at: url) {
            let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [], errorHandler: nil)
            
            while let url = enumerator?.nextObject() as? URL {
                if url.lastPathComponent == ".DS_Store" {
                    continue
                }
                urls.append(url)
            }
        }
        
        return urls
    }
    
    public class func files(at path: String) -> [URL] {
        guard let url = URL(string: "file:///" + path)
            else { return [] }
        
        return files(at: url)
    }
    
    public class func makeSureDirExist(_ path : String) {
        if isDirExist(path) {
            return
        } else {
            mkdir(path)
        }
    }
    
    public class func mkdir(_ path : String) {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            print("Can't create dir at path : " + path)
        }
    }
    
    @discardableResult
    public class func copy(from: URL, to: URL, force: Bool = true) -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: from.absoluteString) else { return false }
        
        if force {
            FS.delete(to)
        }
        
        do {
            try fileManager.copyItem(at: from, to: to)
        } catch _ {
            return false
        }
        
        return true
    }
    
    public class func copy(_ fromPath: String, toPath: String, force: Bool = true) -> Bool
    {
        let fileManager = FileManager.default
        
        // delete destination file if it exist
        if force {
            if fileManager.fileExists(atPath: toPath) {
                do {
                    try fileManager.removeItem(atPath: toPath)
                } catch _ {
                }
            }
        }
        
        do {
            try fileManager.copyItem(atPath: fromPath, toPath: toPath)
            return true
        } catch _ {
            return false
        }
    }
    
    public class func deleteFilesWith(prefix: String, at: URL? = nil) {
        let location = at ?? appFolder()
        let urls = files(at: location)
        
        for url in urls {
            if url.lastPathComponent.hasPrefix(prefix) {
                delete(url, silent: false)
            }
        }
        
    }
    
    public class func delete(_ url: URL, silent: Bool = true) {
        delete(url.path, silent: silent)
    }
    
    public class func delete(_ path : String, silent: Bool = true){
        if !silent {
            print("FS: going to delete file: \(path)")
        }
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error {
            if !silent {
                print("FS: cant delete \(path)")
                print(error)
            }
        }
    }
    
    public class func isFileExists(_ path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }
    
    public class func isFileExists(_ url: URL) -> Bool {
        return (try? url.checkResourceIsReachable()) ?? false
    }
    
}
