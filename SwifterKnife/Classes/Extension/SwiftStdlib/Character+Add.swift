//
//  Character+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

// MARK: - Properties

public extension Character {
    /// Check if character is emoji.
    ///
    ///        Character("😀").isEmoji -> true
    ///
    var isEmoji: Bool {
        return String(self).containEmoji
    }

    /// Integer from character (if applicable).
    ///
    ///        Character("1").int -> 1
    ///        Character("A").int -> nil
    ///
    var int: Int? {
        return Int(String(self))
    }

    /// String from character.
    ///
    ///        Character("a").string -> "a"
    ///
    var string: String {
        return String(self)
    }

    /// Return the character lowercased.
    ///
    ///        Character("A").lowercased -> Character("a")
    ///
    var lowercased: Character {
        return String(self).lowercased().first!
    }

    /// Return the character uppercased.
    ///
    ///        Character("a").uppercased -> Character("A")
    ///
    var uppercased: Character {
        return String(self).uppercased().first!
    }
    
    /// 大写变小写，小写变大写
    var flip: Character? {
        guard let asciiV = self.asciiValue else {
            return nil
        }
        return Character(Unicode.Scalar(asciiV ^ 32))
    }
}

// MARK: - Methods

public extension Character {
    /// Random character.
    ///
    ///    Character.random() -> k
    ///
    /// - Returns: A random character.
    static func randomAlphanumeric() -> Character {
        return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!
    }
}
 
