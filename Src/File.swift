//
//  File.swift
//  KeyMaster
//
//  Created by Loki on 10/25/14.
//  Copyright (c) 2014 CheckaZuja. All rights reserved.
//

import Foundation

public class File {
    
    var file : FileHandle?
    
    let encoding : UInt = String.Encoding.utf8.rawValue
    
    // stuff for reading
    let delimiter : String = "\n"
    var delimiterData : Data
    let chunkSize : Int = 4096
    let buffer : NSMutableData?
    var atEof : Bool = false
    var bytes : UInt64 = 0
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    public var inited : Bool    { return file != nil }
    public var notInited : Bool { return file == nil }
    
    ////////////////////////////////////////////////////////////////////////////////////////
        
    public init(w: String){
        let fileManager = FileManager.default
        
        if (fileManager.fileExists(atPath: w))
        {
            do {
                try fileManager.removeItem(atPath: w)
            } catch _ {
            }
        }
        
        fileManager.createFile(atPath: w, contents: nil, attributes: nil)
        
        file = FileHandle(forWritingAtPath: w)
        
        // this is not necessary for writing, but must be in constructor
        delimiterData = delimiter.data(using: String.Encoding(rawValue: encoding))!
        buffer = NSMutableData(capacity: chunkSize)
    }
    
    public init(r: URL) {
        file = try? FileHandle(forReadingFrom: r)
        // delimiter usually is "\n"
        delimiterData = delimiter.data(using: String.Encoding(rawValue: encoding))!
        // buffer for reading
        buffer = NSMutableData(capacity: chunkSize)
        
        bytes = file!.seekToEndOfFile()
        file!.seek(toFileOffset: 0)
    }
    
    deinit {
        file?.closeFile()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    public func write(_ text : String) -> Int {
        let data = text.data(using: String.Encoding(rawValue: encoding))!
        file?.write(data)
        
        return data.count
    }
    
    public func readln() -> String? {
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer?.range(of: delimiterData, options: NSData.SearchOptions(rawValue: 0), in: NSMakeRange(0, buffer!.length))
        while range!.location == NSNotFound {
            let tmpData : Data? = file!.readData(ofLength: chunkSize)
            if tmpData == nil || tmpData!.count == 0 {
                // EOF or read error.
                atEof = true
                if buffer!.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer! as Data, encoding: encoding);
                    buffer!.length = 0
                    
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer!.append(tmpData!)
            range = buffer!.range(of: delimiterData, options: NSData.SearchOptions(rawValue: 0), in: NSMakeRange(0, buffer!.length))
        }
        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer!.subdata(with: NSMakeRange(0, range!.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer!.replaceBytes(in: NSMakeRange(0, range!.location + range!.length), withBytes: nil, length: 0)
        
        return line as String?
    }
    
    public func flush() {
        file?.synchronizeFile()
    }
    
    public func size() -> Int {
        return Int(bytes)
    }
    
    public func progress() -> Float {
        if file == nil {
            return 0
        }
        let file_sz : Float = Float(bytes);
        let location : Float = Float(file!.offsetInFile);
        
        return location / file_sz;
    }
}
