//
//  TaoToggle.swift
//  TaoGit
//
//  Created by Loki on 14.11.2019.
//  Copyright © 2019 Cheka Zuja. All rights reserved.
//

import SwiftUI

@available(OSX 10.15.0, *)
public struct TaoToggle : View {
    public enum CheckState {
        case on
        case off
        case mixed
        case busy
        
        public var str : String {
            switch self {
            case .on:       return "✓"
            case .off:      return " "
            case .mixed:    return "■"
            case .busy:     return ""
            }
        }
    }
    
    public var state : CheckState = CheckState.off
    public var action : ()-> Void = {}
    
    public init(state: CheckState, action: @escaping ()->Void){
        self.state  = state
        self.action = action
    }
    
    public var body : some View {
        Button(action: {
            self.action()
            
        } ) {
            Text(state.str)
        }
        .frame(width:18, height: 18)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 1)
        )
        .if(state == .busy) { content in
            content.addLoadingCircle()
            .disabled(true)
        }
    }
}


