//
//  CollectionViewItem.swift
//  AppCore
//
//  Created by Loki on 4/4/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import AppKit

open class CollectionViewItem: NSCollectionViewItem {
    public var signals : SignalsService?
    public var key : String = ""
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        textField?.actionChannel()
            .map { ($0.objectValue as? String) ?? ""  }
            .onUpdate(context: self) { ctx, text in                ctx.textField?.isEditable = false
                ctx.signals?.send(signal: CollectionSignal.Rename(key: ctx.key, newName: text))
        }
    }
    
    @IBAction func delete(_ sender: Any) {
        signals?.send(signal: CollectionSignal.Delete(key: key))
    }
    
    @IBAction func rename(_ sender: Any) {
        textField?.isEditable = true
        textField?.becomeFirstResponder()
    }
    
    @IBAction func setImage(_ sender: Any) {
        openImageFile()
    }
    
    func openImageFile() {
        let dialog = NSOpenPanel().then {
            $0.title                   = "Choose a icon file";
            $0.showsResizeIndicator    = true;
            $0.showsHiddenFiles        = false;
            $0.canChooseDirectories    = false;
            $0.canCreateDirectories    = true;
            $0.allowsMultipleSelection = false;
            $0.canChooseFiles          = true;
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let url = dialog.url {
                signals?.send(signal: CollectionSignal.SetIcon(key: key, url: url))
            }
        }
    }
}
