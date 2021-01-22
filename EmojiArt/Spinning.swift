//
//  Spinning.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 15/01/2021.
//

import SwiftUI

struct Spinning: ViewModifier {
    @State var isRotated: Bool = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle.degrees(isRotated ? 360: 0))
            .onAppear {
                withAnimation(animation) {
                    self.isRotated = true
                }
            }
    }
    var animation: Animation {
        Animation.linear(duration: 2).repeatForever(autoreverses: false)
    }
}

extension View {
    func spinning() -> some View {
        return modifier(Spinning())
    }
}
