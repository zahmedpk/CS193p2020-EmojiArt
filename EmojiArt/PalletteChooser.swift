//
//  PalletteChooser.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 16/01/2021.
//

import SwiftUI

struct PalletteChooser: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPallette: String
    var body: some View {
        HStack {
            Stepper(
                onIncrement: { chosenPallette = document.palette(after: chosenPallette) },
                onDecrement: { chosenPallette = document.palette(before: chosenPallette) },
                label: {}
            )
            Text(document.paletteNames[chosenPallette] ?? "")
        }
    }
}
