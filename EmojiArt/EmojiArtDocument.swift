//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 02/01/2021.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    let id: UUID
    static let pallette: String = "⚽️🏀🏈🏏🏓"
    @Published private var emojiArt: EmojiArt
    @Published private(set) var backgroundImage: UIImage?
    private(set) var selectedEmojis: [EmojiArt.Emoji] = []
    private var cancellable: AnyCancellable?
    
    init(id: UUID? = nil) {
        print("constructing a new EmojiArtDocument")
        self.id = id ?? UUID()
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(jsonData: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        cancellable = $emojiArt.sink { (emojiArtNew) in
            UserDefaults.standard.setValue(emojiArtNew.json, forKey: defaultKey)
        }
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
    
    var backgroundURL: URL? {
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
        
        get {
            emojiArt.backgroundURL
        }
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
    func fetchBackgroundImageData(){
        print("fetching a background url")
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    if let imageData = try? Data(contentsOf: url){
                        DispatchQueue.main.async {
                            if url == self.emojiArt.backgroundURL {
                                self.backgroundImage = UIImage(data: imageData)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        print("could not load the image from internet")
                        self.backgroundURL = nil
                    }
                }
            }
            task.resume()
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
        objectWillChange.send()
        deSelect(emoji)
        emojiArt.removeEmoji(emoji)
    }
    func deSelectAllEmojis() {
        objectWillChange.send()
        for emoji in emojiArt.emojis {
            deSelect(emoji)
        }
    }
    func  moveAllSelectedEmojis(by offset: CGSize) {
        objectWillChange.send()
        for emoji in selectedEmojis {
            moveEmoji(emoji: emoji, by: offset)
        }
    }
    func scaleAllSelectedEmojis(by factor: CGFloat) {
        objectWillChange.send()
        for emoji in selectedEmojis {
            scaleEmoji(emoji: emoji, by: factor)
        }
    }
}
