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

import AppKit

public struct Signal {
    public struct WindowDidClose {
        public let sender : Any?
        public let reason : String
        
        public init(sender: Any?, reason: String) {
            self.sender = sender
            self.reason = reason
        }
    }
    
    public struct StatusBar {
        public struct Click {
            public init() {}
        }
    }
}

public struct CollectionSignal {
    public struct Create {
        public init() { }
    }
    public struct Delete {
        public let key: String
        public init(key: String) { self.key = key }
    }
    public struct Rename {
        public let key      : String
        public let newName  : String
        public init(key: String, newName: String) { self.key = key; self.newName = newName}
    }
    public struct SetUrl {
        public let key      : String
        public let url      : URL
        public init(key: String, url: URL) { self.key = key; self.url = url}
    }
    public struct SetIcon {
        public let key      : String
        public let url      : URL
        public init(key: String, url: URL) { self.key = key; self.url = url}
    }
    
    public struct Sort {
        public let descriptors : [NSSortDescriptor]
        public init(descriptors : [NSSortDescriptor]) { self.descriptors = descriptors }
    }
    public struct Filter {
        public let predicate: NSPredicate?
        public init(predicate: NSPredicate?) { self.predicate = predicate }
    }
}
