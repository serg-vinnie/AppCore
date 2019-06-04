//
//  NSViewController+SliderGroup.swift
//  AppCore
//
//  Created by Loki on 5/26/19.
//  Copyright © 2019 Loki. All rights reserved.
//

import Foundation
import AsyncNinja

public extension ExecutionContext where Self: NSViewController {
    func initGroupFor(slider: NSSlider, valueText: NSTextField,  config: ConfigR<Int64>, title: String) {
        
        let sliderValue = slider.rp.integerValue
            .skip(first: 1, last: 0)
            .filter() { $0 != nil }
            .map { Int64($0!) }
        
        sliderValue
            .onUpdate(context: self) { _, value in
                config.value = value
                valueText.isHidden = false
        }
        
        sliderValue
            .map { "\($0) " + title }
            .bind(valueText.rp.stringValue)
        
        sliderValue
            .debounce(interval: 1)
            .delayedUpdate(timeout: 1)
            .onUpdate(context: self) { _,_ in valueText.isHidden = true }
    }
}
