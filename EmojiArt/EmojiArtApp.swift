//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 02/01/2021.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(documentStore)
        }
    }
    var documentStore: EmojiArtDocumentStore{
        EmojiArtDocumentStore()
    }
}
