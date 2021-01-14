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
    @GestureState private var transientZoomScaleForSelection: CGFloat = 1.0
    @GestureState private var transientPanOffset: CGSize = .zero
    
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
    
    @GestureState private var panOffsetForSelection: CGSize = .zero
    func dragGestureForSelection(of emoji: EmojiArt.Emoji) -> some Gesture {
        return DragGesture(minimumDistance: 1.0, coordinateSpace: .local)
            .updating($panOffsetForSelection, body: { (latestValue, state, transaction) in
                state = latestValue.translation
            })
            .onEnded { (finalValue) in
                document.moveAllSelectedEmojis(by: finalValue.translation/zoomScale)
            }
    }
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.pallette.map {String($0)}, id: \.self) {
                        emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiSize))
                            .onDrag {
                                return NSItemProvider(object: emoji as NSString)
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
                                .scaleEffect(zoomScale)
                        )
                        .offset(panOffset)
                        .foregroundColor(.white	)
                        .contentShape(Rectangle())
                        .clipped()
                    ForEach(document.emojis){
                        emoji in
                        Text(emoji.text)
                            .overlay(
                                Group {
                                    if document.isSelected(emoji) {
                                        selectionRectangle(for: emoji)
                                            .contentShape(Rectangle())
          
                                    }
                                }
                            )
                            .position(position(of: emoji, withGeometry: geometry))
                            .font(animatableWithSize: fontSizeForEmoji(emoji))
                            .gesture(tapGestureFor(emoji))
                            .offset(document.isSelected(emoji) ? panOffsetForSelection: .zero)
                            .gesture(document.isSelected(emoji) ? dragGestureForSelection(of: emoji): nil)
                            
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
    func position(of emoji: EmojiArt.Emoji, withGeometry geometry: GeometryProxy) -> CGPoint {
        let x = (CGFloat(emoji.x) ) * zoomScale + panOffset.width
        let y = (CGFloat(emoji.y) ) * zoomScale + panOffset.height
        let x2 = x + geometry.size.width/2
        let y2 = y + geometry.size.height/2
        let pos =  CGPoint(x: x2, y: y2)
        return pos
    }
    func setZoomToFitBackgroundImage(in geometry: GeometryProxy){
        if let image = document.backgroundImage, image.size.height > 0 ,image.size.width > 0  {
            let hZoom = geometry.size.width / image.size.width
            let vZoom = geometry.size.height / image.size.height
            document.setPan(newPan: .zero)
            document.setZoomScale(newZoomScale:  min(hZoom, vZoom))
        }
    }
    
    func selectionRectangle(for emoji: EmojiArt.Emoji) -> some View {
        return RoundedRectangle(cornerRadius: 5)
            .stroke(Color.blue, lineWidth: 3)
            .frame(minWidth: 30, minHeight: 30)
            .overlay(   Image(systemName: "trash")
                            .resizable()
                            .foregroundColor(Color.blue)
                            .frame(width: 20, height: 20, alignment: .top)
                            .offset(x: 15, y: -15)
                            .onTapGesture {
                                document.remove(emoji)
                            }
                        , alignment: .topTrailing)
    }
    func tapGestureFor(_ emoji: EmojiArt.Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                if document.isSelected(emoji) {
                    document.deSelect(emoji)
                } else {
                    document.select(emoji)
                }
            }
    }
    func fontSizeForEmoji(_ emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size) * zoomScale * (document.isSelected(emoji) ? transientZoomScaleForSelection : 1.0)
    }
}
