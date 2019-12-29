//
//  LoadingCircleView.swift
//  TaoGit
//
//  Created by UKS on 25.11.2019.
//  Copyright © 2019 Cheka Zuja. All rights reserved.
//

import Foundation
import SwiftUI


@available(OSX 10.15, *)
public struct LoadingCircleView: View {
    @State var spinGreenCircle = false
    @State var trimGreenCircle = false
    
    @State var diameter: CGFloat = 0
    @State var caliber: CGFloat = 0
    
    @State var backColor: Color = Color.purple
    @State var frontColor: Color = Color.green
    
    public init(diameter: CGFloat, caliber: CGFloat, backColor:Color = Color.purple, frontColor:Color = Color.green){
        self.diameter = diameter
        self.caliber = caliber
        self.backColor = backColor
        self.frontColor = frontColor
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(backColor, lineWidth: caliber)
                .opacity(0.2)
                .frame(width: diameter, height: diameter)
            
            Circle()
                .trim(from: trimGreenCircle ? 0 : 0, to: trimGreenCircle ? 0.25 : 0)
                .stroke(frontColor, lineWidth: caliber)
                .frame(width: diameter, height: diameter)
                .animation(
                    Animation
                        .linear(duration: 1)
                        .speed(1/3)
                )
                .rotationEffect(.degrees(spinGreenCircle ? 0 : -360*4), anchor: .center)
                .animation(
                    Animation
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .speed(1/3)
                )
                .onAppear() {
                        self.spinGreenCircle.toggle()
                        self.trimGreenCircle.toggle()
                }
        }
    }
}


@available(OSX 10.15, *)
public extension View {
    func addLoadingCircle(diameter: CGFloat = 20, caliber: CGFloat = 4) -> some View{
        return self.modifier(LoadingCircleModifier(diameter:diameter, caliber:caliber ))
    }
}

@available(OSX 10.15, *)
public struct LoadingCircleModifier: ViewModifier {
    @State var diameter: CGFloat
    @State var caliber: CGFloat

    public func body(content: Content) -> some View {
        ZStack {
            content
            
            LoadingCircleView(diameter: diameter, caliber: caliber)
        }
    }
}
