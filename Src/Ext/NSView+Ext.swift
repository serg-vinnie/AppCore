//
//  UIViewExtensions.swift
//  TimeTracker
//
//  Created by Loki on 10/13/17.
//  Copyright © 2017 checkaZuja. All rights reserved.
//
#if os(macOS)
import AppKit
public extension NSView {
    
    /** This is the function to get subViews of a view of a particular type
     */
    func subViews<T : NSView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : NSView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: NSView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
    
    func fitTo(view: NSView) {
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
#endif
