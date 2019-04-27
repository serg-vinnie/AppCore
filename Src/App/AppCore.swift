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
import Swinject

public class AppCore {
    
    public static let env           : ServiceEnvironment = environment()
    public static let scenes        = container.resolve(Scenes.self)!
    public static let signals       = container.resolve(SignalsService.self)!
    public static let states        = container.resolve(StatesService.self)!
    public static let bundle        = Bundle.main
    
    // Containers
    public static var mvvmContainer : Container?    // MVVMController resolves ViewModel from this container
    public static let container     = AppCoreContainer(env: env)
}

public extension AppCore {
    static func log(title: String, msg: String, thread: Bool = false) {
        if thread {
            print("[\(title)] (\(Thread.current.dbgName)) \(msg)")
        } else {
            print("[\(title)]: \(msg)")
        }
    }
    
    static func log(title: String, error: Error, thread: Bool = false) {
        if thread {
            print("[\(title) ERROR] (\(Thread.current.dbgName)) \(error.localizedDescription)")
        }else {
            print("[\(title) ERROR] \(error.localizedDescription)")
        }
    }
}


