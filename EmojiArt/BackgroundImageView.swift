//
//  BackgroundImageView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 14/01/2021.
//

import SwiftUI

struct BackgroundImageView: View {
    let image: UIImage?
    let zoomScale: CGFloat
    let panOffset: CGSize
    var body: some View {
        Rectangle()
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .overlay(
                OptionalImage(uiImage: image)
                    .scaleEffect(zoomScale)
            )
            .offset(panOffset)
            .foregroundColor(.white    )
            .contentShape(Rectangle())
            .clipped()
    }
}
