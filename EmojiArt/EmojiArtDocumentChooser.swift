//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 20/01/2021.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var documentStore: EmojiArtDocumentStore
    var body: some View {
        NavigationView {
            List {
                ForEach(documentStore.documents){
                    document in
                    NavigationLink(documentStore.name(for: document), destination: EmojiArtDocumentView(document: document)
                                    .navigationBarTitle(documentStore.name(for: document)))
                }
            }
            .navigationBarTitle(documentStore.name)
            .navigationBarItems(leading: Button(action: {
                documentStore.addDocument()
            }, label: {
                Image(systemName: "plus")
            }))
        }
    }
}
