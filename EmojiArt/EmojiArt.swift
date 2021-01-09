//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 02/01/2021.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable {
        let text : String
        //coorindate system is 0,0 in center
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        let emoji = Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId)
        emojis.append(emoji)
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(jsonData: Data?){
        if let json = jsonData, let emojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json){
            self = emojiArt
        } else {
            return nil
        }
    }
    init(){ }
}
