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

public extension Thread {
    
    var dbgName: String {
        if let currentOperationQueue = OperationQueue.current?.name {
            
            if currentOperationQueue.contains("OperationQueue") {
                return currentOperationQueue
            } else {
                return "OperationQueue: \(currentOperationQueue)"
            }
            
        } else if let underlyingDispatchQueue = OperationQueue.current?.underlyingQueue?.label {
            
            if underlyingDispatchQueue.contains("DispatchQueue") {
                return underlyingDispatchQueue
            } else {
                return "DispatchQueue: \(underlyingDispatchQueue)"
            }
            
        } else {
            let name = __dispatch_queue_get_label(nil)
            return String(cString: name, encoding: .utf8) ?? Thread.current.description
        }
    }
}
