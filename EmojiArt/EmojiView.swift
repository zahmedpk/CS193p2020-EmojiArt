//
//  EmojiView.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 14/01/2021.
//

import SwiftUI

struct EmojiView: View {
    let geometry: GeometryProxy
    let document: EmojiArtDocument
    let emoji: EmojiArt.Emoji
    let zoomScale: CGFloat
    let panOffset: CGSize
    var transientZoomScaleForSelection: CGFloat
    var panOffsetForSelection: CGSize
    var body: some View {
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
}
