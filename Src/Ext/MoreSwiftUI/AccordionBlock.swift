//
//  Accordion.swift
//  AppCore
//
//  Created by UKS_neo on 15.01.2020.
//  Copyright © 2020 Loki. All rights reserved.
//

import Foundation
import SwiftUI

@available(OSX 10.15, *)
public struct AccordionBlock : View {
    @State var collapsed: Bool = false
    @Binding var header: String
    //var subView: some View
    
    public init (header: Binding<String>)//, subView: some View )
    {
        _header = header
        //self.subView = subView
    }
    
    public var body : some View {
        VStack {
            Button ( action: { self.collapsed.toggle() } ){
                HStack{
                    Text( collapsed ? "+" : "-" )
                        .font(.system(size: 20))
                        .animation(.easeInOut)
                        .frame(width: 15)
                    
                    Text("Header")
                        .font(.system(size: 15))
                    
                    Spacer()
                }.padding(4)
            }.buttonStyle( PlainButtonStyle() )
            .background(Color(hex: 0x444444))
            
            if !collapsed {
                HStack {
                    Text("test")
                    Spacer()
                }.padding(5)
                .background(Color(hex: 0x777777))
            }
        }
    }
}

