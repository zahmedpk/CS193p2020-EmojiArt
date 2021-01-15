//
//  EmojiView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 14/01/2021.
//

import SwiftUI

struct EmojiView: View {
    let geometry: GeometryProxy
    @EnvironmentObject var document: EmojiArtDocument
    let emoji: EmojiArt.Emoji
    let zoomScale: CGFloat
    let panOffset: CGSize
    @Binding var panOffsetForSelection: CGSize
    @Binding var transientZoomScaleForSelection: CGFloat
    var body: some View {
        Text(emoji.text)
            .overlay(
                Group {
                    if document.isSelected(emoji) {
                        selectionRectangle(for: emoji)
                    }
                }
            )
            .position(position(of: emoji, withGeometry: geometry))
            .font(animatableWithSize: fontSizeForEmoji(emoji))
            .gesture(tapGestureFor(emoji))
            .offset(document.isSelected(emoji) ? panOffsetForSelection: .zero)
            .gesture(document.isSelected(emoji) ? dragGestureForSelection(): nil)
    }
    func position(of emoji: EmojiArt.Emoji, withGeometry geometry: GeometryProxy) -> CGPoint {
        let x = (CGFloat(emoji.x) ) * zoomScale + panOffset.width
        let y = (CGFloat(emoji.y) ) * zoomScale + panOffset.height
        let x2 = x + geometry.size.width/2
        let y2 = y + geometry.size.height/2
        let pos =  CGPoint(x: x2, y: y2)
        return pos
    }
    func selectionRectangle(for emoji: EmojiArt.Emoji) -> some View {
        return RoundedRectangle(cornerRadius: 5)
            .stroke(Color.blue, lineWidth: 3)
            .frame(minWidth: 40, minHeight: 40)
            .overlay( deleteButtonOverlay , alignment: .topTrailing)
    }
    
    var deleteButtonOverlay: some View {
        Image(systemName: "trash")
                        .resizable()
                        .contentShape(Rectangle())
                        .foregroundColor(Color.blue)
                        .frame(width: 30, height: 30, alignment: .top)
                        .offset(x: 20, y: -20)
                        .onTapGesture {
                            document.remove(emoji)
                        }
    }
    
    func fontSizeForEmoji(_ emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size) * zoomScale * (document.isSelected(emoji) ? transientZoomScaleForSelection : 1.0)
    }
    func tapGestureFor(_ emoji: EmojiArt.Emoji) -> some Gesture {
        return TapGesture().onEnded {
            if document.isSelected(emoji) {
                document.deSelect(emoji)
            } else {
                document.select(emoji)
            }
        }
    }
    func dragGestureForSelection() -> some Gesture {
        return DragGesture(minimumDistance: 1.0, coordinateSpace: .local)
            .onChanged({ (latestValue) in
                panOffsetForSelection = latestValue.translation
            })
            .onEnded { (finalValue) in
                document.moveAllSelectedEmojis(by: finalValue.translation/zoomScale)
                panOffsetForSelection = .zero
            }
    }
}
