//
//  MenuBarView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 14/01/2021.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var document: EmojiArtDocument
    let defaultEmojiSize: CGFloat
    @State var chosenPallette: String = ""
    
    init(defaultEmojiSize: CGFloat, document: EmojiArtDocument) {
        self.document = document
        self.defaultEmojiSize = defaultEmojiSize
        _chosenPallette = State(wrappedValue: document.defaultPalette)
    }
    
    var body: some View {
        HStack {
            PalletteChooser(chosenPallette: $chosenPallette)
                .fixedSize()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(chosenPallette.map {String($0)}, id: \.self) {
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
}
