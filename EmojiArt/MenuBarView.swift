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
    @State private var showPaletteEditor = false
    
    init(defaultEmojiSize: CGFloat, document: EmojiArtDocument) {
        self.document = document
        self.defaultEmojiSize = defaultEmojiSize
        _chosenPallette = State(wrappedValue: document.defaultPalette)
    }
    
    var body: some View {
        HStack {
            PalletteChooser(chosenPallette: $chosenPallette)
                .fixedSize()
            Image(systemName: "keyboard")
                .imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                .sheetOrPopover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: $chosenPallette, showPaletteEditor: $showPaletteEditor)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500, alignment: .center)
                }
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

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State var paletteName: String = ""
    @State var emojisToAdd: String = ""
    @Binding var showPaletteEditor: Bool
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button("Done", action: {showPaletteEditor = false}).padding(.horizontal)
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            document.renamePalette(chosenPalette, to: paletteName)
                        }
                    })
                    .onAppear {
                        paletteName = document.paletteNames[chosenPalette] ?? ""
                    }
                    TextField("Add Emojis", text: $emojisToAdd) { began in
                        if !began {
                            chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    }
                    Section(header: Text("Remove Emojis")) {
                        ScrollView(.vertical) {
                            EmojiGrid(chosenPalette: $chosenPalette, document: document)
                        }
                    }
                }
            }
        }
    }
}


struct EmojiGrid : View {
    @Binding var chosenPalette: String
    @ObservedObject var document: EmojiArtDocument
    var cols: [GridItem] = [ GridItem(.adaptive(minimum: 50)) ]
    var body: some View {
        LazyVGrid(columns: cols, spacing: 10){
            ForEach(chosenPalette.map{String($0)}, id: \.self) {
                emoji in
                Text(emoji)
                    .font(Font.system(size: 40))
                    .onTapGesture {
                        chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                    }
            }
        }
    }
}
