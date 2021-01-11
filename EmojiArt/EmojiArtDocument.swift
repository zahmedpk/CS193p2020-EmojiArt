//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 02/01/2021.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static let pallette: String = "⚽️🏀🏈🏏🏓"
    @Published private var emojiArt: EmojiArt {
        didSet {
            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    }
    @Published private(set) var backgroundImage: UIImage?
    private static let untitled = "EmojiArt.untitled"
    private var selectedEmojis: [EmojiArt.Emoji] = []
    
    init() {
        emojiArt = EmojiArt(jsonData: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    // MARK:- accessors
    
    var emojis: [EmojiArt.Emoji] {
        emojiArt.emojis
    }
    var zoomScale: CGFloat {
        emojiArt.zoomScale
    }
    var panOffset: CGSize {
        emojiArt.panOffset
    }
    
    func isSelected(_ emoji: EmojiArt.Emoji) -> Bool {
        return selectedEmojis.contains(matching: emoji)
    }
    
    // MARK:- intents
    func addEmoji(emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(text: emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    func moveEmoji(emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(where: {$0.id == emoji.id}){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    func scaleEmoji(emoji: EmojiArt.Emoji, by scale: CGFloat){
        if let index = emojiArt.emojis.firstIndex(where: {$0.id == emoji.id}){
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    func setBackground(url: URL?){
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    func fetchBackgroundImageData(){
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    func setZoomScale(newZoomScale: CGFloat) {
        emojiArt.zoomScale = newZoomScale
    }
    func setPan(newPan: CGSize) {
        emojiArt.panOffset = newPan
    }
    func select(_ emoji: EmojiArt.Emoji) {
        objectWillChange.send()
        if !selectedEmojis.contains(matching: emoji){
            selectedEmojis.append(emoji)
        }
    }
    func deSelect(_ emoji: EmojiArt.Emoji) {
        objectWillChange.send()
        if let index = selectedEmojis.firstIndex(matching: emoji){
            selectedEmojis.remove(at: index)
        }
    }
    func remove(_ emoji: EmojiArt.Emoji) {
        emojiArt.removeEmoji(emoji)
    }
}
