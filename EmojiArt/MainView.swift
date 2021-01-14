//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 02/01/2021.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var document: EmojiArtDocument
    private let defaultEmojiSize: CGFloat = 40
    @GestureState private var transientZoomScale: CGFloat = 1.0
    @GestureState private var transientPanOffset: CGSize = .zero
    
    @GestureState private var transientZoomScaleForSelection: CGFloat = 1.0
    @State private var panOffsetForSelection: CGSize = .zero
    
    var zoomScale: CGFloat {
        document.zoomScale * transientZoomScale
    }
    
    var panOffset: CGSize {
        (document.panOffset + transientPanOffset) * zoomScale
    }
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($transientZoomScale) { (latestValue, state, transaction) in
                state = latestValue
            }
            .onEnded { (finalZoomScale) in
                document.setZoomScale(newZoomScale: finalZoomScale*document.zoomScale)
            }
    }
    var magnificationGestureForSelection: some Gesture {
        MagnificationGesture()
            .updating($transientZoomScaleForSelection) { (latestValue, state, transaction) in
                state = latestValue
            }
            .onEnded { finalValue in
                document.scaleAllSelectedEmojis(by: finalValue)
            }
    }
    var panGesture: some Gesture {
        DragGesture()
            .updating($transientPanOffset) { latestValue, state, transaction in
                state = latestValue.translation / zoomScale
            }
            .onEnded { finalValue in
                document.setPan(newPan: document.panOffset + finalValue.translation/zoomScale)
            }
    }
    
    var body: some View {
        VStack {
            MenuBarView(emojiPallette: EmojiArtDocument.pallette, defaultEmojiSize: defaultEmojiSize)
            GeometryReader {
                geometry in
                ZStack {
                    BackgroundImageView(image: document.backgroundImage, zoomScale: zoomScale, panOffset: panOffset)
                    ForEach(document.emojis){
                        emoji in
                        EmojiView(geometry: geometry, emoji: emoji, zoomScale: zoomScale, panOffset: panOffset, transientZoomScaleForSelection: transientZoomScaleForSelection, panOffsetForSelection: $panOffsetForSelection).environmentObject(document)
                    }
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) {
                    providers, location in
                    let localLocation = geometry.convert(location, from: CoordinateSpace.global)
                    let localWithCenterOrigin = CGPoint(x: localLocation.x - geometry.size.width/2, y: localLocation.y - geometry.size.height/2)
                    
                    let localWithCenterOriginZoomAdjusted = CGPoint(x: (localWithCenterOrigin.x - panOffset.width) / zoomScale, y: (localWithCenterOrigin.y - panOffset.height) / zoomScale)
                    
                    return self.drop(providers: providers, location: localWithCenterOriginZoomAdjusted)
                }
                .gesture(panGesture)
                .onTapGesture(count: 2) {
                    withAnimation {
                        setZoomToFitBackgroundImage(in: geometry)
                    }
                }
                .onTapGesture {
                    document.deSelectAllEmojis()
                }
                .gesture(document.selectedEmojis.count > 0 ? magnificationGestureForSelection : nil)
                .gesture(document.selectedEmojis.count == 0 ? magnificationGesture : nil)
                
            }
            .clipped()
        }
    }
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) {
            url in
            document.setBackground(url: url.imageURL)
        }
        if !found {
            found = providers.loadFirstObject(ofType: String.self) {
                string in
                self.document.addEmoji(emoji: string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
    
    func setZoomToFitBackgroundImage(in geometry: GeometryProxy){
        if let image = document.backgroundImage, image.size.height > 0 ,image.size.width > 0  {
            let hZoom = geometry.size.width / image.size.width
            let vZoom = geometry.size.height / image.size.height
            document.setPan(newPan: .zero)
            document.setZoomScale(newZoomScale:  min(hZoom, vZoom))
        }
    }
    
    func fontSizeForEmoji(_ emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size) * zoomScale * (document.isSelected(emoji) ? transientZoomScaleForSelection : 1.0)
    }
}
