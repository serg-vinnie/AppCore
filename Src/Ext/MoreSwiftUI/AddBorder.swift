//
//  AddBorder.swift
//  AppCore
//
//  Created by UKS_neo on 29.12.2019.
//  Copyright © 2019 Loki. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
public extension View {
    @available(OSX 10.15, *)
    func addBorder(color: Color, radius: Int, lineWidth: Int) -> some View
    {
         self.modifier( CustomBorder(color: color, radius: CGFloat(radius), lineWidth: CGFloat(lineWidth) ) )
    }
}

@available(OSX 10.15, *)
public struct CustomBorder: ViewModifier {
    @State var color: Color
    @State var radius: CGFloat
    @State var lineWidth: CGFloat
    
    public func body (content: Content) -> some View
    {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
}
