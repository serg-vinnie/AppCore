//
//  MVVMController.swift
//  FocusitoMac
//
//  Created by Loki on 8/7/18.
//  Copyright © 2018 checkazuja. All rights reserved.
//

import AppKit
import RxSwift

public protocol MVVMControllerProtocol : class {
    func closeWith(reason: String)
}

open class MVVMController<MyView,MyViewModel> : NSViewController, NSWindowDelegate, MVVMControllerProtocol where MyView : NSView {
    public var      bag                = DisposeBag()
    public lazy var myView             = { view as! MyView }()
    public var      myViewModel        : MyViewModel! { didSet { viewModelDidSet() } }
    open var        wndShouldClose     : Bool { return true }
    open var        fixedSizeView      : Bool { return false }
    open var        setTitle           : String { return "" }
    open var        resolveViewModel   : Bool { return true }
    open var        allowMultiInstances: Bool { return false }
    
    weak var sheetController : NSViewController?
    
    open func viewModelDidSet() {
        
    }
    
    deinit {
        AppCore.log(title: "\(type(of:self))", msg: "deinit")
    }
    
    
    override open func viewDidLoad() {
        if resolveViewModel {
            let container = AppCore.mvvmContainer ?? AppCore.container
            if let viewModel = container.resolve(MyViewModel.self) {
                myViewModel = viewModel
            }
        }
        
        if fixedSizeView {
            DispatchQueue.main.async {
                self.view.window!.styleMask.remove(.resizable)
            }
        }
    }
    
    override open func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.delegate = self
        if setTitle.count > 0 {
            view.window?.title = setTitle
        }
    }
    
    override open func viewDidAppear() {
        if !allowMultiInstances {
            if let info = AppCore.states.valueFor(key: type(of:self)) as ViewStateInfo? {
                if info.state == .didShow && info.controller != self {
                    info.mvvmController()?.closeWith(reason: "duplicate")
                }
            }
        }
        AppCore.states.set(value: ViewStateInfo(controller: self, state: .didShow) , forKey: type(of:self))
    }
    
    override open func viewDidDisappear() {
        AppCore.states.set(value: ViewStateInfo(controller: self, state: .didHide(reason: "viewDidDisappear")) , forKey: type(of:self))
    }
    
    // NSWindowDelegate
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        if wndShouldClose {
            closeNotify(reason: "user")
        }
        return wndShouldClose
    }
    
    public func closeWith(reason: String) {
        closeNotify(reason: reason)
        if self.parent != nil {
            dismiss(self)
        } else {
            view.window?.close()
        }
    }
    
    private func closeNotify(reason: String) {
        log(msg: "closed by [\(reason)]")
        
        AppCore.states.set(value: ViewStateInfo(controller: self, state: .didHide(reason: reason)) , forKey: type(of:self))
        AppCore.signals.send(signal: Signal.WindowDidClose(sender: self, reason: reason))
    }
}

public extension MVVMController {
    func presentSheet(_ viewController: NSViewController?) {
        if sheetController === viewController {
            return
        }
        if sheetController is MVVMControllerProtocol {
            (sheetController as? MVVMControllerProtocol)?.closeWith(reason: "sheetUpdate")
        } else {
            sheetController?.view.window?.close()
        }
        
        
        if let controller = viewController {
            presentAsSheet(controller)
        }
    }
}

public extension NSViewController {
    func log(msg: String) {
        AppCore.log(title: "\(type(of:self))", msg: msg)
    }
    
    func log(error: Error) {
        AppCore.log(title: "\(type(of:self))", error: error)
    }
}
