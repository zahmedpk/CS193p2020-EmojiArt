//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 02/01/2021.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    private let defaultEmojiSize: CGFloat = 40
    var body: some View {
        VStack {
            MenuBarView(defaultEmojiSize: defaultEmojiSize, document: document).environmentObject(document)
            if backgroundImageIsLoading {
                Group {
                    Image(systemName: "hourglass")
                        .imageScale(.large)
                        .aspectRatio(contentMode: .fit)
                        .spinning()
                }
                .frame(maxHeight: .infinity)
            } else {
                GeometryReader {
                    geometry in
                    DocumentView(defaultEmojiSize: .constant(defaultEmojiSize), geometry: geometry).environmentObject(document)
                }
                .clipped()
            }
        }.navigationBarItems(trailing: Button(action: {
            if let url = UIPasteboard.general.url {
                document.backgroundURL = url
            }
        }, label: {
            Image(systemName: "doc.on.clipboard")
        }))
    }
    var backgroundImageIsLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
}
