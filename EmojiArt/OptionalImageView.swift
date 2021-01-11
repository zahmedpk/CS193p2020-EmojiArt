//
//  OptionalImageView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 09/01/2021.
//
import SwiftUI

struct OptionalImage: View {
    let uiImage: UIImage?
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
