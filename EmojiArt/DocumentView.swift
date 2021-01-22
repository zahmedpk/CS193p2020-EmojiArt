//
//  DocumentView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 14/01/2021.
//

import SwiftUI

struct DocumentView: View {
    @EnvironmentObject var document: EmojiArtDocument
    @State private var transientZoomScaleForSelection: CGFloat = 1.0
    @GestureState private var transientZoomScale: CGFloat = 1.0
    @GestureState private var transientPanOffset: CGSize = .zero
    @State private var panOffsetForSelection: CGSize = .zero
    @Binding var defaultEmojiSize: CGFloat
    let geometry: GeometryProxy
    var magnificationGestureForSelection: some Gesture {
        MagnificationGesture()
            .onChanged({ latestValue in
                transientZoomScaleForSelection = latestValue
            })
            .onEnded { finalValue in
                document.scaleAllSelectedEmojis(by: finalValue)
                transientZoomScaleForSelection = 1.0
            }
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
    var zoomScale: CGFloat {
        document.zoomScale * transientZoomScale
    }
    
    var panOffset: CGSize {
        (document.panOffset + transientPanOffset) * zoomScale
    }
    var body: some View {
        ZStack {
            BackgroundImageView(image: document.backgroundImage, zoomScale: zoomScale, panOffset: panOffset)
            ForEach(document.emojis){
                emoji in
                EmojiView(geometry: geometry, emoji: emoji, zoomScale: zoomScale, panOffset: panOffset,panOffsetForSelection: $panOffsetForSelection, transientZoomScaleForSelection: $transientZoomScaleForSelection)
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
        .onReceive(document.$backgroundImage, perform: { _ in
            setZoomToFitBackgroundImage(in: geometry)
        })
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
    func setZoomToFitBackgroundImage(in geometry: GeometryProxy){
        if let image = document.backgroundImage, image.size.height > 0 ,image.size.width > 0, geometry.size
            .height > 0, geometry.size.width > 0 {
            let hZoom = geometry.size.width / image.size.width
            let vZoom = geometry.size.height / image.size.height
            document.setPan(newPan: .zero)
            document.setZoomScale(newZoomScale:  min(hZoom, vZoom))
        }
    }
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) {
            url in
            document.backgroundURL = url
        }
        if !found {
            found = providers.loadFirstObject(ofType: String.self) {
                string in
                self.document.addEmoji(emoji: string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
}
