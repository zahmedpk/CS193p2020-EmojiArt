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
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.pallette.map {String($0)}, id: \.self) {
                        emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiSize))
                            .onDrag {
                                print("on drag emoji")
                                return NSItemProvider(object: emoji as NSString)
                            }
                            .onTapGesture {
                                print("Emoji tapped")
                            }
                    }
                }.padding(.horizontal)
            }
            
            GeometryReader {
                geometry in
                ZStack {
                    Rectangle()
                        .edgesIgnoringSafeArea([.horizontal, .bottom])
                        .overlay(
                            OptionalImage(uiImage: document.backgroundImage)
                        )
                        .foregroundColor(.yellow)
                        .contentShape(Rectangle())
                        .clipped()
                    ForEach(document.emojis){
                        emoji in
                        Text(emoji.text)
                            .position(CGPoint(x: emoji.x, y: emoji.y))
                            .font(Font.system(size: CGFloat(emoji.size)))
                    }
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) {
                    providers, location in
                    let localLocation = geometry.convert(location, from: CoordinateSpace.global)
                    return self.drop(providers: providers, location: localLocation)
                }
                .onTapGesture {
                    print("ZStack tapped")
                }
            }
            .clipped()
        }
    }
    
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
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        print("got a dropped item \(providers[0])")
        var found = providers.loadFirstObject(ofType: URL.self) {
            url in
            print("url is \(url) and imgURL is \(url.imageURL)")
            document.setBackground(url: url.imageURL)
        }
        if !found {
            found = providers.loadFirstObject(ofType: String.self) {
                string in
                self.document.addEmoji(emoji: string, at: location, size: defaultEmojiSize)
                print("dropped emoji is \(string)")
            }
        }
        return found
    }
}
