//
//  Spinning.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 15/01/2021.
//

import SwiftUI

struct Spinning: ViewModifier {
    @State var angle = Angle.degrees(0)
    func body(content: Content) -> some View {
        content
            .rotationEffect(angle)
            .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false))
            .onAppear {
                self.angle = Angle.degrees(360)
            }
    }
}

extension View {
    func spinning() -> some View {
        return modifier(Spinning())
    }
}
