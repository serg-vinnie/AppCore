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
import AppKit

protocol SceneViewItemProtocol : class {
    var id          : String                { get }
    var storyboard  : NSStoryboard          { get }
    var controller  : NSViewController?     { get set }
    var wnd         : NSWindowController?   { get set }
}

class SceneViewItemStrong : SceneViewItemProtocol {
    let id          : String
    let storyboard  : NSStoryboard
    var controller  : NSViewController?
    var wnd         : NSWindowController?
    
    init(id: String, storyboard: NSStoryboard) {
        self.id = id
        self.storyboard = storyboard
    }
}

class SceneViewItem : SceneViewItemProtocol {
    let id          : String
    let storyboard  : NSStoryboard
    weak var controller  : NSViewController?
    weak var wnd         : NSWindowController?
    
    init(id: String, storyboard: NSStoryboard) {
        self.id = id
        self.storyboard = storyboard
    }
}

public class Scenes {
    
    private var items = [Int:SceneViewItemProtocol]()
    
    public func register<VC>(key: VC.Type, id: String, story: NSStoryboard, strongRef: Bool = false) { //where VC : NSViewController {
        let hash = ObjectIdentifier(key).hashValue
        if let _ = items[hash] {
            AppCore.log(title: "Scenes", msg: "key \(key) registered already")
        } else {
            if strongRef {
                items[hash] = SceneViewItemStrong(id: id, storyboard: story)
            } else {
                items[hash] = SceneViewItem(id: id, storyboard: story)
            }
        }
    }
    
    public func resolve<VC>( _ hash: Int) -> VC? where VC : NSViewController {
        guard let item = items[hash]
            else { return nil }
        if item.controller == nil {
            item.controller = item.storyboard.viewController(id: item.id) as? VC
        }
        
        return item.controller as? VC
    }
    
    public func resolve<WC>(wnd: Int) -> WC? where WC : NSWindowController {
        guard let item = items[wnd]
            else { return nil }
        
        if item.wnd == nil {
            item.wnd = item.storyboard.windowController(id: item.id) as? WC
        }

        return item.wnd as? WC
    }
    
    public func resolve<WC>(wnd: WC.Type) -> WC? where WC : NSWindowController {
        return resolve(wnd: ObjectIdentifier(wnd).hashValue) as? WC
    }
    
    public func resolve<VC>(_ key: VC.Type) -> VC? where VC : NSViewController {
        return resolve(ObjectIdentifier(key).hashValue) as? VC
    }
    
    public func show<VC>(_ key: VC.Type) where VC : NSViewController {
        if let vc = resolve(key) {
            presentInWindow(vc: vc)
        } else {
            AppCore.log(title: "Scenes", msg: "can't resolve View Controller : \(key)")
        }
    }
    
    public func show<WC>(wnd: WC.Type) {
        show(wnd: ObjectIdentifier(wnd).hashValue)
    }
    
    public func show(wnd: Int) {
        if let wc = resolve(wnd: wnd) {
            if wc.window?.isVisible ?? false {
                NSApp.activate(ignoringOtherApps: true)
                wc.window?.makeKeyAndOrderFront(nil)
            } else {
                wc.showWindow(nil)
            }
            
        } else {
            AppCore.log(title: "Scenes", msg: "can't resolve Window Controller : \(wnd)")
            assert(false)
        }
    }
    
    public func showIntegrityFailure() {
        let name = Bundle.main.infoDictionary?["CFBundleName"] ?? "application"
        alert(msg: "Application Integrity Failure", text: "please delete \(name) and reinstall it again from App Store")
    }
}

private extension Scenes {
    func presentInWindow(vc: NSViewController) {
        let wnd = NSWindow(contentViewController: vc)
        let wndController = NSWindowController(window: wnd)
        wndController.showWindow(self)
    }
    
    func alert(msg: String, text: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = msg
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
