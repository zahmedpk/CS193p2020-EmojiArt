//
//  MenuBarView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 14/01/2021.
//

import SwiftUI

struct MenuBarView: View {
    let emojiPallette: String
    let defaultEmojiSize: CGFloat
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojiPallette.map {String($0)}, id: \.self) {
                    emoji in
                    Text(emoji)
                        .font(Font.system(size: defaultEmojiSize))
                        .onDrag {
                            return NSItemProvider(object: emoji as NSString)
                        }
                }
            }.padding(.horizontal)
        }
    }
}
