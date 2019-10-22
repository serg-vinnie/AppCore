//
//  AppCoreController.swift
//  AppCore
//
//  Created by Loki on 20.10.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
open class AppCoreController<MyView,MyViewModel> : NSHostingController<MyView> where MyView : View  {
	public var      viewModel       	: MyViewModel! { didSet { viewModelDidSet() } }
	open var        resolveViewModel   	: Bool { return true }
	
	@objc required dynamic public init?(coder: NSCoder) {
		super.init(coder: coder, rootView: AppCore.container.resolve(MyView.self)!)
		
	}
	
    override open func viewDidLoad() {
        if resolveViewModel {
            if let viewModel = AppCore.container.resolve(MyViewModel.self) {
				self.viewModel = viewModel
			}
        }
	}
	
	open func viewModelDidSet() {
        
    }
}
