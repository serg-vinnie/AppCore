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
import AsyncNinja

final public class SignalsService {
    public static var main : SignalsService = { return SignalsService() }()
    var dispatchers = [Int:Any]()
    var subscribeNotifiers = [Int:Producer<Void,Void>]()
    
    public init() {}
    
    public func send<Signal>(signal: Signal) {
        let hash = ObjectIdentifier(Signal.self).hashValue
        if let dispatcher = dispatchers[hash] as? SignalDispatcher<Signal> {
            dispatcher.send(signal)
        }
    }
    
    public func subscribeFor<Signal>(_ signalType: Signal.Type) -> Producer<Signal,Void> {
        subscribeNotifier(signalType)?.update(())
        return getDispatcher(signalType).dispatcher
    }
    
    public func onSubscribe<Signal>(_ signalType: Signal.Type) -> Producer<Void,Void> {
        if let producer = subscribeNotifier(signalType) {
            return producer
        } else {
            let hash = ObjectIdentifier(Signal.self).hashValue
            subscribeNotifiers[hash] = Producer<Void,Void>()
            return subscribeNotifiers[hash]!
        }
    }
}

private extension SignalsService {
    func getDispatcher<Signal>(_ signalType: Signal.Type) -> SignalDispatcher<Signal> {
        let hash = ObjectIdentifier(Signal.self).hashValue
        if let dispatcher = dispatchers[hash] as? SignalDispatcher<Signal> {
            return dispatcher
        } else {
            let dispatcher = SignalDispatcher<Signal>()
            dispatchers[hash] = dispatcher
            return dispatcher
        }
    }
    
    func subscribeNotifier<Signal>(_ signalType: Signal.Type) -> Producer<Void,Void>? {
        let hash = ObjectIdentifier(Signal.self).hashValue
        return subscribeNotifiers[hash]
    }
}
