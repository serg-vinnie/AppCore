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
        HStack (alignment: .top, spacing: 0) {
            VStack (alignment: .leading, spacing: 0) {
                GeometryReader { geometry in
                    Button ( action: { self.collapsed.toggle() } ){
                        HStack{
                            Text( self.collapsed ? "+" : "-" )
                                .font(.system(size: 20))
                                .animation(.easeInOut)
                                .padding(.leading, 8)
                            
                            Text( self.header )
                                .font(.system(size: 15))
                            
                            Spacer()
                        }.frame(width: geometry.size.width)
                        
                    }.buttonStyle( PlainButtonStyle() )
                    .background(Color(hex: 0x444444))
                }
                
                if !collapsed {
                    HStack (alignment: .top, spacing: 0) {
                        Text("test")
                        Spacer()
                    }.padding(5)
                    .background(Color(hex: 0x777777))
                }
                
                Spacer()
            }
        }
    }
}

